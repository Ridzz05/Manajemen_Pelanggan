import 'package:flutter/material.dart';
import '../../../models/service.dart';

/// Service card widget for displaying individual services
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  final Function(String) onActionSelected;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: ValueKey(service.id), // Add key for better performance
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material( // Use Material for better ink response
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading icon - cached category color/icon
                _CategoryIcon(category: service.category),
                const SizedBox(width: 12),

                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Category and duration row
                      Row(
                        children: [
                          _CategoryChip(category: service.category),
                          const SizedBox(width: 8),
                          Text(
                            service.durationInDays != null
                                ? '${service.durationInDays} hari'
                                : 'Tidak ditentukan',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing area
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price
                    Text(
                      'Rp ${service.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Popup menu with optimized constraints
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 120,
                        maxWidth: 120,
                      ),
                      onSelected: onActionSelected,
                      itemBuilder: (BuildContext context) => const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
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
      ),
    );
  }
}

// Optimized category widgets for better performance
class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getCategoryIcon(category),
        color: color,
        size: 20,
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
        return Colors.grey;
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
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
        return Colors.grey;
    }
  }
}
