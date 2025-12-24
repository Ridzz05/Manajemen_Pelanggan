import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.1),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 12),
                          _buildSearchBar(context, isWide),
                        ],
                      ),
                    ),
                  ),
                  Consumer<CustomerProvider>(
                    builder: (context, customerProvider, child) {
                      if (customerProvider.isLoading) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (customerProvider.filteredCustomers.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            child: _buildEmptyState(),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final customer = customerProvider.filteredCustomers[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildCustomerCard(customer, isWide),
                              );
                            },
                            childCount: customerProvider.filteredCustomers.length,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.people_alt_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Pelanggan',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kelola semua data pelanggan Anda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isWide) {
    final colorScheme = Theme.of(context).colorScheme;
    final verticalPadding = isWide ? 10.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                context.read<CustomerProvider>().searchCustomers(value);
              },
              decoration: const InputDecoration(
                hintText: 'Cari pelanggan...',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: colorScheme.outline,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
                context.read<CustomerProvider>().searchCustomers('');
              },
              tooltip: 'Bersihkan',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pelanggan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan tombol + untuk menambah pelanggan',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, bool isWide) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarRadius = isWide ? 26.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detail pelanggan: ${customer.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(isWide ? 16 : 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getContactMethodIcon(customer.contactMethod),
                          size: 16,
                          color: _getContactMethodColor(customer.contactMethod),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.contactValue,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (customer.selectedServiceName != null && customer.selectedServiceName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 14,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Layanan: ${customer.selectedServiceName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showCustomerDetailDialog(context, customer),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: 'Detail Layanan',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditCustomerDialog(context, customer);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, customer);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: Text('Apakah Anda yakin ingin menghapus pelanggan "${customer.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<CustomerProvider>().deleteCustomer(customer.id!);
                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pelanggan "${customer.name}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus pelanggan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerDetailDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Pelanggan: ${customer.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customer.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _getContactMethodIcon(customer.contactMethod),
                            color: _getContactMethodColor(customer.contactMethod),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_getContactValueLabel(customer.contactMethod)}: ${customer.contactValue}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (customer.selectedServiceName != null && customer.selectedServiceName!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Layanan: ${customer.selectedServiceName}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status Timer Layanan',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Timer akan berjalan mengikuti durasi layanan yang dipilih',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Durasi: ${customer.selectedServiceName != null ? "Berdasarkan layanan" : "Belum ada layanan"}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final contactValueController = TextEditingController(text: customer.contactValue);

    String selectedContactMethod = customer.contactMethod;
    final availableContactMethods = ['WA Business', 'Telegram', 'Email'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama pelanggan',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedContactMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metode Kontak',
                  ),
                  items: availableContactMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Row(
                        children: [
                          Icon(
                            _getContactMethodIcon(method),
                            color: _getContactMethodColor(method),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(method),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedContactMethod = value!;
                    contactValueController.clear();
                  },
                ),
                TextField(
                  controller: contactValueController,
                  decoration: InputDecoration(
                    labelText: _getContactValueLabel(selectedContactMethod),
                    hintText: _getContactValueHint(selectedContactMethod),
                    prefixIcon: Icon(
                      _getContactMethodIcon(selectedContactMethod),
                      color: _getContactMethodColor(selectedContactMethod),
                    ),
                  ),
                  keyboardType: _getContactValueKeyboardType(selectedContactMethod),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || contactValueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua field harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final updatedCustomer = customer.copyWith(
                  name: nameController.text,
                  contactMethod: selectedContactMethod,
                  contactValue: contactValueController.text,
                  phone: contactValueController.text, // Also set phone for compatibility
                  address: '',
                  updatedAt: DateTime.now(),
                );

                final success = await context.read<CustomerProvider>().updateCustomer(updatedCustomer);
                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pelanggan berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal memperbarui pelanggan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  IconData _getContactMethodIcon(String method) {
    switch (method) {
      case 'WA Business':
        return Icons.business_rounded;
      case 'Telegram':
        return Icons.telegram_rounded;
      case 'Email':
        return Icons.email_rounded;
      default:
        return Icons.contact_mail_rounded;
    }
  }

  Color _getContactMethodColor(String method) {
    switch (method) {
      case 'WA Business':
        return Colors.green;
      case 'Telegram':
        return Colors.blue;
      case 'Email':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getContactValueLabel(String method) {
    switch (method) {
      case 'WA Business':
        return 'No. WA Business';
      case 'Telegram':
        return 'Username Telegram';
      case 'Email':
        return 'Alamat Email';
      default:
        return 'Kontak';
    }
  }

  String _getContactValueHint(String method) {
    switch (method) {
      case 'WA Business':
        return 'Contoh: 08123456789';
      case 'Telegram':
        return 'Contoh: @username';
      case 'Email':
        return 'Contoh: nama@email.com';
      default:
        return 'Masukkan kontak';
    }
  }

  TextInputType _getContactValueKeyboardType(String method) {
    switch (method) {
      case 'WA Business':
        return TextInputType.phone;
      case 'Telegram':
        return TextInputType.text;
      case 'Email':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }
}
