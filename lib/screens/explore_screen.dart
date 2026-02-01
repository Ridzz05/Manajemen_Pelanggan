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
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 16),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pelanggan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Kelola data pelanggan',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isWide) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final verticalPadding = isWide ? 10.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
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
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: colorScheme.onSurfaceVariant,
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
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pelanggan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan tombol + untuk menambah',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCustomerDetailDialog(context, customer);
        },
        child: Padding(
          padding: EdgeInsets.all(isWide ? 16 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getContactMethodIcon(customer.contactMethod),
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
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
                    if (customer.selectedServiceName != null && customer.selectedServiceName!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Layanan: ${customer.selectedServiceName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showEditCustomerDialog(context, customer),
                color: colorScheme.onSurfaceVariant,
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
            TextButton(
              onPressed: () async {
                final success = await context.read<CustomerProvider>().deleteCustomer(customer.id!);
                if (!context.mounted) return;
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
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
          title: Text('Detail Pelanggan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nama'),
                  subtitle: Text(customer.name),
                ),
                ListTile(
                  leading: Icon(_getContactMethodIcon(customer.contactMethod)),
                  title: Text(customer.contactMethod),
                  subtitle: Text(customer.contactValue),
                ),
                if (customer.selectedServiceName != null)
                  ListTile(
                    leading: const Icon(Icons.layers_outlined),
                    title: const Text('Layanan'),
                    subtitle: Text(customer.selectedServiceName!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditCustomerDialog(context, customer);
              },
              child: const Text('Edit'),
            ),
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
    // This part should launch the AddCustomerScreen in edit mode ideally, 
    // or just show a simple dialog as before but styled cleaner.
    // For now, I'll keep the dialog approach but cleaner.
    
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
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedContactMethod = value!;
                  },
                ),
                TextField(
                  controller: contactValueController,
                  decoration: const InputDecoration(
                    labelText: 'Kontak',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
               onPressed: () => _showDeleteConfirmation(context, customer),
               style: TextButton.styleFrom(foregroundColor: Colors.red),
               child: const Text('Hapus'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                 final updatedCustomer = customer.copyWith(
                  name: nameController.text,
                  contactMethod: selectedContactMethod,
                  contactValue: contactValueController.text,
                  updatedAt: DateTime.now(),
                );

                final success = await context.read<CustomerProvider>().updateCustomer(updatedCustomer);
                if (!context.mounted) return;
                Navigator.of(context).pop(); // Close edit dialog

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pelanggan diperbarui')),
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
      case 'WA Business': return Icons.business_outlined;
      case 'Telegram': return Icons.telegram;
      case 'Email': return Icons.email_outlined;
      default: return Icons.contact_mail_outlined;
    }
  }
}
