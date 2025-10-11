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

    // Update available categories from provider and local state
    final serviceProvider = context.read<ServiceProvider>();
    final providerCategories = serviceProvider.allCategories
        .where((cat) => cat != 'Semua')
        .toSet();

    // Merge provider categories with local categories only if needed
    final needsUpdate = !_availableCategories.containsAll(providerCategories) ||
                       !providerCategories.containsAll(_availableCategories);

    if (needsUpdate) {
      setState(() {
        _availableCategories.addAll(providerCategories);
      });
    }

    // Ensure selected category is valid
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
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
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
        title: Text(
          'Tambah Layanan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: TextButton(
                  onPressed: _isLoading ? null : _saveService,
                  child: Text(
                    'Simpan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
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
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_business_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tambah Layanan Baru',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Buat layanan baru dengan detail lengkap untuk pelanggan',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form Fields
                  Text(
                    'Detail Layanan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Layanan',
                      hintText: 'Masukkan nama layanan',
                      prefixIcon: Icon(
                        Icons.business_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama layanan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Harga (Rp)',
                      hintText: 'Masukkan harga layanan',
                      prefixIcon: Icon(
                        Icons.attach_money_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Harga harus lebih dari 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Start Date Field
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _startDate = pickedDate;
                          // If end date is before start date, clear it
                          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                            _endDate = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _startDate == null
                              ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                              : Theme.of(context).colorScheme.primary,
                          width: _startDate == null ? 1 : 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Mulai',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _startDate == null
                                      ? 'Pilih tanggal mulai'
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _startDate == null
                                        ? Theme.of(context).colorScheme.outline
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // End Date Field
                  InkWell(
                    onTap: _startDate == null ? null : () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? _startDate!,
                        firstDate: _startDate!,
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _endDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _startDate == null
                            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _startDate == null
                              ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                              : (_endDate == null
                                  ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.primary),
                          width: _startDate == null ? 1 : (_endDate == null ? 1 : 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: _startDate == null
                                ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Berakhir',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _startDate == null
                                        ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _endDate == null
                                      ? 'Pilih tanggal berakhir'
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _startDate == null
                                        ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                                        : (_endDate == null
                                            ? Theme.of(context).colorScheme.outline
                                            : Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_startDate != null)
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              key: const ValueKey('category_dropdown'), // Add key for better performance
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: allCategories.map((category) {
                                return DropdownMenuItem(
                                  key: ValueKey('category_$category'), // Add key for each item
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(category),
                                        color: _getCategoryColor(category),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
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
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          key: const ValueKey('add_category_button'),
                          onPressed: () {
                            print('Add category button pressed'); // Debug log
                            _showAddCategoryDialog(context);
                          },
                          icon: const Icon(Icons.add_rounded),
                          tooltip: 'Tambah Kategori Baru',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Preview Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pratinjau',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                  _selectedCategory,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(_selectedCategory),
                                color: _getCategoryColor(_selectedCategory),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameController.text.isEmpty
                                        ? 'Nama Layanan'
                                        : _nameController.text,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _priceController.text.isEmpty
                                  ? 'Rp 0'
                                  : 'Rp ${_priceController.text}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                  _selectedCategory,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedCategory,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: _getCategoryColor(
                                        _selectedCategory,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Tambah Layanan',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'perawatan':
        return Colors.green;
      case 'perbaikan':
        return Colors.orange;
      case 'pembersihan':
        return Colors.blue;
      case 'modifikasi':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'perawatan':
        return Icons.build_rounded;
      case 'perbaikan':
        return Icons.handyman_rounded;
      case 'pembersihan':
        return Icons.cleaning_services_rounded;
      case 'modifikasi':
        return Icons.tune_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    print('Showing add category dialog'); // Debug log

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Tambah Kategori Baru'),
          content: Form(
            key: _categoryFormKey,
            child: TextFormField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Masukkan nama kategori baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                if (_availableCategories.contains(value.trim())) {
                  return 'Kategori sudah ada';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _newCategoryController.clear();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Tambah button pressed in dialog'); // Debug log
                if (_categoryFormKey.currentState!.validate()) {
                  _addNewCategory();
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _addNewCategory() {
    print('Adding new category'); // Debug log
    final newCategory = _newCategoryController.text.trim();

    if (newCategory.isNotEmpty && !_availableCategories.contains(newCategory)) {
      print('Category is valid, adding...'); // Debug log

      // Add to available categories and update selected category
      setState(() {
        _availableCategories.add(newCategory);
        _selectedCategory = newCategory;
        _newCategoryController.clear();
      });

      // Create a placeholder service entry for the new category
      _createPlaceholderServiceForCategory(newCategory);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori "$newCategory" berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('Category validation failed - empty: ${newCategory.isEmpty}, exists: ${_availableCategories.contains(newCategory)}'); // Debug log

      // Show error message if category already exists or is empty
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
