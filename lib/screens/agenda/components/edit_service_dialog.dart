import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../models/service.dart';

/// Dialog for editing service information
class EditServiceDialog extends StatefulWidget {
  final Service service;

  const EditServiceDialog({
    super.key,
    required this.service,
  });
  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  String _selectedCategory = 'Perawatan';
  String _selectedDurationPeriod = '1 minggu';
  final List<String> _availableCategories = ['Perawatan', 'Perbaikan', 'Pembersihan', 'Modifikasi'];
  final List<String> _availableDurationPeriods = ['1 minggu', '2 minggu', '3 minggu', '1 bulan'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _selectedCategory = widget.service.category;
    _selectedDurationPeriod = widget.service.durationPeriod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Layanan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Layanan',
                hintText: 'Masukkan nama layanan',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                hintText: 'Masukkan harga layanan',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDurationPeriod,
              decoration: const InputDecoration(
                labelText: 'Durasi Layanan',
              ),
              items: _availableDurationPeriods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDurationPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
              ),
              items: _availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
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
          onPressed: _handleSave,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _handleSave() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan harga layanan harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedService = widget.service.copyWith(
      name: _nameController.text,
      price: double.parse(_priceController.text),
      durationPeriod: _selectedDurationPeriod,
      category: _selectedCategory,
      updatedAt: DateTime.now(),
    );

    final success = await context.read<ServiceProvider>().updateService(updatedService);

    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui layanan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
