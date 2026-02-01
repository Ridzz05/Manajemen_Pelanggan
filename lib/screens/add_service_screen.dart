import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  String _selectedCategory = 'Website';
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _availableCategories = {'Website', 'Aplikasi', 'Desain'};

  final _formKey = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Update available categories from provider
    final serviceProvider = context.read<ServiceProvider>();
    final providerCategories = serviceProvider.allCategories
        .where((cat) => cat != 'Semua')
        .toSet();

    final needsUpdate = !_availableCategories.containsAll(providerCategories) ||
                       !providerCategories.containsAll(_availableCategories);

    if (needsUpdate) {
      setState(() {
        _availableCategories.addAll(providerCategories);
      });
    }

    if (!_availableCategories.contains(_selectedCategory) && _availableCategories.isNotEmpty) {
      _selectedCategory = _availableCategories.first;
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Layanan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveService,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildFormFields(context),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveService,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Tambah Layanan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Layanan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi informasi layanan baru Anda',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Layanan',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Nama layanan tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: 'Harga (Rp)',
            prefixIcon: Icon(Icons.attach_money_outlined),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Harga tidak boleh kosong';
            final price = double.tryParse(value);
            if (price == null || price <= 0) return 'Harga harus lebih dari 0';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDatePicker(context, 'Mulai', _startDate, (date) {
               setState(() {
                  _startDate = date;
                  if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                    _endDate = null;
                  }
               });
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildDatePicker(context, 'Selesai', _endDate, (date) {
               setState(() {
                 _endDate = date;
               });
            }, firstDate: _startDate)),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategoryDropdown(context),
      ],
    );
  }

  Widget _buildDatePicker(
      BuildContext context, String label, DateTime? date, Function(DateTime) onSelect, {DateTime? firstDate}) {
    return InkWell(
      onTap: () async {
        final initial = date ?? (firstDate ?? DateTime.now());
        final start = DateTime(2000); // Allow past dates starting from year 2000
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: start,
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        if (picked != null) onSelect(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<ServiceProvider>(
            builder: (context, serviceProvider, child) {
              // Get categories from provider
              final providerCategories = serviceProvider.allCategories
                  .where((cat) => cat != 'Semua')
                  .toSet();

              // Merge with local categories
              final allCategories = providerCategories.union(_availableCategories).toList();

              // Ensure selected category is valid
              if (!allCategories.contains(_selectedCategory) && allCategories.isNotEmpty) {
                _selectedCategory = allCategories.first;
              }

              return DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: allCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: () => _showAddCategoryDialog(context),
          icon: const Icon(Icons.add),
          tooltip: 'Tambah Kategori',
        ),
      ],
    );
  }
  
  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: Form(
          key: _categoryFormKey,
          child: TextFormField(
            controller: _newCategoryController,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Harus diisi';
              if (_availableCategories.contains(value.trim())) return 'Sudah ada';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (_categoryFormKey.currentState!.validate()) {
                _addNewCategory();
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addNewCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty && !_availableCategories.contains(newCategory)) {
      setState(() {
        _availableCategories.add(newCategory);
        _selectedCategory = newCategory;
        _newCategoryController.clear();
      });
      
      // Update provider
      context.read<ServiceProvider>().addCategory(newCategory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori "$newCategory" berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newCategory.isEmpty
              ? 'Nama kategori tidak boleh kosong'
              : 'Kategori "$newCategory" sudah ada'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _createPlaceholderServiceForCategory(String category) async {
    try {
      // Create a placeholder service entry for the new category
      final placeholderService = Service(
        name: 'Kategori: $category', // Placeholder name
        price: 0.0, // Zero price for placeholder
        startDate: DateTime.now(), // Default start date for placeholder
        endDate: DateTime.now().add(const Duration(days: 30)), // Default 30 days for placeholder
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to database via provider
      final success = await context.read<ServiceProvider>().addService(placeholderService);

      if (success) {
        print('Placeholder service created for category: $category');
        // Force refresh of categories in provider
        await context.read<ServiceProvider>().loadServices();
      } else {
        print('Failed to create placeholder service for category: $category');
      }
    } catch (e) {
      print('Error creating placeholder service: $e');
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal berakhir harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = Service(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        startDate: _startDate,
        endDate: _endDate,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await context.read<ServiceProvider>().addService(service);

      if (success) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan "${service.name}" berhasil ditambahkan'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan layanan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
