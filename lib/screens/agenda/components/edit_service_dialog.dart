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
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _availableCategories = ['Perawatan', 'Perbaikan', 'Pembersihan', 'Modifikasi'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _selectedCategory = widget.service.category;
    _startDate = widget.service.startDate;
    _endDate = widget.service.endDate;
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

    final updatedService = widget.service.copyWith(
      name: _nameController.text,
      price: double.parse(_priceController.text),
      startDate: _startDate,
      endDate: _endDate,
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
