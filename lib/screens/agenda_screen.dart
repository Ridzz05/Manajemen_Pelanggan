import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';
import '../providers/customer_provider.dart';
import 'agenda/service_detail_screen.dart';
import 'edit_service_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
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
                        const SizedBox(height: 16),
                        Consumer<ServiceProvider>(
                          builder: (context, provider, child) {
                            return _buildCategoryFilter(context, provider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Consumer2<ServiceProvider, CustomerProvider>(
                  builder: (context, serviceProvider, customerProvider, child) {
                    if (serviceProvider.isLoading) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Prepare data: filter categories if a selection is made
                    var displayCategories = serviceProvider.categories;
                    if (serviceProvider.searchQuery.isNotEmpty) {
                       displayCategories = displayCategories.where((c) => c.toLowerCase().contains(serviceProvider.searchQuery.toLowerCase())).toList();
                    } else if (serviceProvider.selectedCategory != 'Semua') {
                       displayCategories = [serviceProvider.selectedCategory];
                    }

                    if (displayCategories.isEmpty) {
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
                            final category = displayCategories[index];
                            final customerCount = customerProvider.getCustomersByCategory(category).length;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCategoryListItem(context, category, customerCount),
                            );
                          },
                          childCount: displayCategories.length,
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
          'Layanan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Kelola semua layanan',
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
                context.read<ServiceProvider>().searchServices(value);
              },
              decoration: const InputDecoration(
                hintText: 'Cari layanan...',
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
                context.read<ServiceProvider>().searchServices('');
              },
              tooltip: 'Bersihkan',
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem(BuildContext context, String category, int customerCount) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ServiceDetailScreen(categoryName: category)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                 Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.layers_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$customerCount Pelanggan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ServiceProvider provider) {
    final theme = Theme.of(context);
    // Ensure 'Semua' is always first and unique
    final categories = ['Semua', ...provider.categories.where((c) => c != 'Semua')];
    final selectedCategory = provider.selectedCategory;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: categories.map((category) {
          // Accessing the private field via a new getter I need to create
          final isSelected = category == (provider.selectedCategory); 
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                context.read<ServiceProvider>().filterByCategory(category);
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada layanan',
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

  void _navigateToEditServiceScreen(BuildContext context, Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(service: service),
      ),
    );
  }
  
  void _showServiceDetailDialog(BuildContext context, Service service) {
    // Simple detail dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harga: Rp ${service.price}'),
            if (service.durationInDays != null)
              Text('Durasi: ${service.durationInDays} hari'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Layanan'),
          content: Text('Apakah Anda yakin ingin menghapus layanan "${service.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final success = await context.read<ServiceProvider>().deleteService(service.id!);
                if (!context.mounted) return;
                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Layanan "${service.name}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus layanan'),
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
}
