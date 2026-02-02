import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/service_provider.dart';
import '../models/customer.dart';
import 'package:intl/intl.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customerToEdit;

  const AddCustomerScreen({super.key, this.customerToEdit});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactValueController = TextEditingController();

  String _selectedContactMethod = 'WA Business';
  final List<String> _availableContactMethods = ['WA Business', 'Telegram', 'Email'];
  
  // New Fields
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedCategories = [];

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Start animation
    _animationController.forward();

    // Pre-fill if editing
    if (widget.customerToEdit != null) {
      final c = widget.customerToEdit!;
      _nameController.text = c.name;
      _selectedContactMethod = c.contactMethod;
      _contactValueController.text = c.contactValue;
      _startDate = c.startDate;
      _endDate = c.endDate;
      _selectedCategories.addAll(c.serviceCategories);
    }

    // Load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _contactValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.customerToEdit != null ? 'Edit Pelanggan' : 'Pelanggan Baru'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: TextButton(
              onPressed: _isLoading ? null : _saveCustomer,
              child: Text('Simpan', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Informasi Dasar'),
                  const SizedBox(height: 16),
                  _buildNameField(theme),
                  const SizedBox(height: 24),
                  _buildContactSection(theme, colorScheme),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Detail Layanan'),
                  const SizedBox(height: 16),
                  _buildDateSection(context),
                  const SizedBox(height: 24),
                  _buildCategorySection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nama Pelanggan',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
    );
  }

  Widget _buildContactSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _availableContactMethods.map((method) {
              final isSelected = _selectedContactMethod == method;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedContactMethod = method);
                  },
                  avatar: isSelected ? null : Icon(_getContactMethodIcon(method), size: 18),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contactValueController,
          decoration: InputDecoration(
            labelText: _getContactValueLabel(_selectedContactMethod),
            hintText: _getContactValueHint(_selectedContactMethod),
            prefixIcon: Icon(_getContactMethodIcon(_selectedContactMethod)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: _getContactValueKeyboardType(_selectedContactMethod),
          validator: (value) => value == null || value.isEmpty ? 'Kontak wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Row(
      children: [
        Expanded(
          child: _buildDatePickerField(
            context, 
            'Mulai', 
            _startDate, 
            (date) => setState(() {
              _startDate = date;
              // Auto-adjust end date if needed
              if (_endDate != null && _endDate!.isBefore(date)) {
                _endDate = null;
              }
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDatePickerField(
            context, 
            'Selesai', 
            _endDate, 
            (date) => setState(() => _endDate = date),
            firstDate: _startDate,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, DateTime? date, Function(DateTime) onSelect, {DateTime? firstDate}) {
    return InkWell(
      onTap: () async {
        final initial = date ?? (firstDate ?? DateTime.now());
        final result = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (result != null) onSelect(result);
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
            Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                style: TextStyle(
                  color: date != null 
                      ? Theme.of(context).colorScheme.onSurface 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Layanan',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ServiceProvider>(
          builder: (context, provider, child) {
            final categories = provider.categories.where((c) => c != 'Semua').toList();
            
            if (categories.isEmpty) {
              return Text(
                'Belum ada kategori. Tambahkan di menu Layanan.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate dates
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai harus diisi'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Validate categories (optional, but usually at least one is needed)
    if (_selectedCategories.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu kategori'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        id: widget.customerToEdit?.id, // Preserve ID if editing
        name: _nameController.text.trim(),
        contactMethod: _selectedContactMethod,
        contactValue: _contactValueController.text.trim(),
        phone: _selectedContactMethod == 'WA Business' ? _contactValueController.text.trim() : '',
        address: '', // Optional now
        startDate: _startDate,
        endDate: _endDate,
        serviceCategories: _selectedCategories,
        createdAt: widget.customerToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.customerToEdit != null) {
        success = await context.read<CustomerProvider>().updateCustomer(customer);
      } else {
        success = await context.read<CustomerProvider>().addCustomer(customer);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.customerToEdit != null 
                ? 'Data pelanggan berhasil diperbarui' 
                : 'Pelanggan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan pelanggan'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Icons Helper
  IconData _getContactMethodIcon(String method) {
    switch (method) {
      case 'WA Business': return Icons.whatshot;
      case 'Telegram': return Icons.send;
      case 'Email': return Icons.email;
      default: return Icons.contact_page;
    }
  }

  String _getContactValueLabel(String method) => '$method Contact';
  String _getContactValueHint(String method) => 'Enter $method info';
  TextInputType _getContactValueKeyboardType(String method) {
    if (method == 'Email') return TextInputType.emailAddress;
    if (method == 'WA Business') return TextInputType.phone;
    return TextInputType.text;
  }
}
