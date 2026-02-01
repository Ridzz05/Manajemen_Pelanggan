import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/service_provider.dart';
import '../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

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
  int? _selectedServiceId;
  String? _selectedServiceName;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
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
        title: Text(
          'Pelanggan Baru',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
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
                  onPressed: _isLoading ? null : _saveCustomer,
                  child: Text(
                    'Simpan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
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
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Name Section
                  Text(
                    'Nama',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    autofocus: true, // Auto-focus enabled
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nama Depan & Belakang',
                      hintStyle: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.outline.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),

                  // 2. Contact Method Section
                  Text(
                    'Hubungi lewat apa?',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, // Gap between chips
                    runSpacing: 12,
                    children: _availableContactMethods.map((method) {
                      final isSelected = _selectedContactMethod == method;
                      return ChoiceChip(
                        label: Text(method),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedContactMethod = method;
                              // Optional: Clear value if switching types drastically, 
                              // but keeping it might be better for UX in case of accidental switch
                            });
                          }
                        },
                        avatar: isSelected ? null : Icon(
                          _getContactMethodIcon(method),
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 3. Contact Value Input
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: TextFormField(
                      key: ValueKey(_selectedContactMethod), // Force rebuild on change
                      controller: _contactValueController,
                      decoration: InputDecoration(
                        labelText: _getContactValueLabel(_selectedContactMethod),
                        hintText: _getContactValueHint(_selectedContactMethod),
                        prefixIcon: Icon(
                          _getContactMethodIcon(_selectedContactMethod),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      keyboardType: _getContactValueKeyboardType(_selectedContactMethod),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                            return 'Kontak wajib diisi';
                         }
                         // Simple validation logic
                         if (_selectedContactMethod == 'Email' && !value.contains('@')) {
                            return 'Format email tidak valid';
                         }
                         return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Service Selection (Optional)
                  Text(
                    'Tertarik layanan apa? (Opsional)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<ServiceProvider>(
                    builder: (context, serviceProvider, child) {
                      final services = serviceProvider.services;
                      
                      if (services.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Belum ada layanan tersedia',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }

                      return DropdownButtonFormField<int>(
                        value: _selectedServiceId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                        ),
                        hint: const Text('Pilih salah satu layanan'),
                        items: [
                           const DropdownMenuItem(
                            value: null,
                            child: Text('Tidak memilih layanan sekarang'),
                          ),
                          ...services.map((service) {
                            return DropdownMenuItem(
                              value: service.id,
                              child: Text(
                                service.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceId = value;
                            if (value != null) {
                              final selectedService = services.firstWhere((s) => s.id == value);
                              _selectedServiceName = selectedService.name;
                            } else {
                              _selectedServiceName = null;
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
           color: colorScheme.surface,
           border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
         ),
         child: SafeArea(
           child: SizedBox(
             width: double.infinity,
             height: 52,
             child: FilledButton(
               onPressed: _isLoading ? null : _saveCustomer,
               style: FilledButton.styleFrom(
                 backgroundColor: theme.colorScheme.primary,
                 foregroundColor: theme.colorScheme.onPrimary,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16),
                 ),
                 elevation: 0,
               ),
               child: _isLoading
                   ? SizedBox(
                       width: 24,
                       height: 24,
                       child: CircularProgressIndicator(
                         color: theme.colorScheme.onPrimary,
                         strokeWidth: 2.5,
                       ),
                     )
                   : const Text(
                       'Simpan Pelanggan',
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                     ),
             ),
           ),
         ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customer = Customer(
        name: _nameController.text.trim(),
        contactMethod: _selectedContactMethod,
        contactValue: _contactValueController.text.trim(),
        phone: _selectedContactMethod == 'WA Business' ? _contactValueController.text.trim() : '', 
        address: '', 
        selectedServiceId: _selectedServiceId,
        selectedServiceName: _selectedServiceName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await context.read<CustomerProvider>().addCustomer(customer);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} berhasil disimpan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menyimpan data'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
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

  // Helper methods
  IconData _getContactMethodIcon(String method) {
    switch (method) {
      case 'WA Business': return Icons.whatshot_rounded; // Using a clearly distinct icon for WA if needed, or stick to business
      case 'Telegram': return Icons.send_rounded;
      case 'Email': return Icons.email_rounded;
      default: return Icons.contact_page_rounded;
    }
  }

  String _getContactValueLabel(String method) {
    switch (method) {
      case 'WA Business': return 'Nomor WhatsApp';
      case 'Telegram': return 'Username Telegram';
      case 'Email': return 'Alamat Email';
      default: return 'Info Kontak';
    }
  }

  String _getContactValueHint(String method) {
    switch (method) {
      case 'WA Business': return 'Contoh: 0812xxx';
      case 'Telegram': return 'Contoh: @username';
      case 'Email': return 'nama@email.com';
      default: return '';
    }
  }

  TextInputType _getContactValueKeyboardType(String method) {
    switch (method) {
      case 'WA Business': return TextInputType.phone;
      case 'Email': return TextInputType.emailAddress;
      default: return TextInputType.text;
    }
  }
}
