import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _newCategoryController;

  String _selectedCategory = 'Website';
  DateTime? _startDate;
  DateTime? _endDate;

  final Set<String> _availableCategories = {'Website', 'Aplikasi', 'Desain'};

  final _formKey = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.service.name);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _selectedCategory = widget.service.category;
    _startDate = widget.service.startDate;
    _endDate = widget.service.endDate;
    _newCategoryController = TextEditingController();

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

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final serviceProvider = context.read<ServiceProvider>();
    final providerCategories = serviceProvider.categories
        .where((cat) => cat != 'Semua')
        .toSet();

    final needsUpdate =
        !_availableCategories.containsAll(providerCategories) ||
        !providerCategories.containsAll(_availableCategories);

    if (needsUpdate) {
      setState(() {
        _availableCategories.addAll(providerCategories);
      });
    }

    if (!_availableCategories.contains(_selectedCategory) &&
        _availableCategories.isNotEmpty) {
      _selectedCategory = _availableCategories.first;
    }
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
        title: const Text('Edit Layanan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateService,
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
                      onPressed: _isLoading ? null : _updateService,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan Perubahan'),
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
          'Edit Layanan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Perbarui detail layanan ini',
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
              final providerCategories = serviceProvider
                  .categories
                  .where((cat) => cat != 'Semua')
                  .toSet();

              // Merge with local categories
              final allCategories = providerCategories
                  .union(_availableCategories)
                  .toList();

              // Ensure selected category is valid
              if (!allCategories.contains(_selectedCategory) &&
                  allCategories.isNotEmpty) {
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
      context.read<ServiceProvider>().addCategory(newCategory);
    }
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal harus lengkap')));
        return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedService = widget.service.copyWith(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
      );

      await context.read<ServiceProvider>().updateService(updatedService);

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan berhasil diperbarui')),
          );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui layanan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}