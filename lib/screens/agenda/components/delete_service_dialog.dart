import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../models/service.dart';

class DeleteServiceDialog extends StatelessWidget {
  final Service service;

  const DeleteServiceDialog({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Layanan'),
      content: Text('Apakah Anda yakin ingin menghapus layanan "${service.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await context.read<ServiceProvider>().deleteService(service.id!);

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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
