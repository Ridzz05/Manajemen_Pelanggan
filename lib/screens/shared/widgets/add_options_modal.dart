import 'package:flutter/material.dart';

/// Modal bottom sheet for add options (Customer & Service)
class AddOptionsModal extends StatelessWidget {
  final VoidCallback onAddCustomer;
  final VoidCallback onAddService;

  const AddOptionsModal({
    super.key,
    required this.onAddCustomer,
    required this.onAddService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tambah Baru',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Add Customer Option
          _buildOptionTile(
            context,
            icon: Icons.person_add_rounded,
            title: 'Tambah Pelanggan',
            subtitle: 'Tambahkan pelanggan baru ke sistem',
            color: Theme.of(context).colorScheme.primary,
            onTap: onAddCustomer,
          ),

          const SizedBox(height: 12),

          // Add Service Option
          _buildOptionTile(
            context,
            icon: Icons.add_business_rounded,
            title: 'Tambah Layanan',
            subtitle: 'Tambahkan layanan baru untuk pelanggan',
            color: Theme.of(context).colorScheme.secondary,
            onTap: onAddService,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}

/// Utility function to show add options modal
void showAddOptionsModal({
  required BuildContext context,
  required VoidCallback onAddCustomer,
  required VoidCallback onAddService,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return AddOptionsModal(
        onAddCustomer: onAddCustomer,
        onAddService: onAddService,
      );
    },
  );
}
