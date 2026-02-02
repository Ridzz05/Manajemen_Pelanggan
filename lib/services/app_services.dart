import 'package:flutter/material.dart';
class ValidationService {
  static Map<String, String?> validateServiceForm({
    required String name,
    required String description,
    required String price,
    required String duration,
    required String category,
  }) {
    Map<String, String?> errors = {};
 
    if (name.trim().isEmpty) {
      errors['name'] = 'Nama layanan tidak boleh kosong';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Deskripsi tidak boleh kosong';
    }

    if (price.trim().isEmpty) {
      errors['price'] = 'Harga tidak boleh kosong';
    } else {
      final priceNum = double.tryParse(price);
      if (priceNum == null || priceNum <= 0) {
        errors['price'] = 'Harga harus berupa angka yang valid dan lebih dari 0';
      }
    }

    if (duration.trim().isEmpty) {
      errors['duration'] = 'Durasi tidak boleh kosong';
    } else {
      final durationNum = int.tryParse(duration);
      if (durationNum == null || durationNum <= 0) {
        errors['duration'] = 'Durasi harus berupa angka yang valid dan lebih dari 0';
      }
    }

    if (category.trim().isEmpty) {
      errors['category'] = 'Kategori harus dipilih';
    }

    return errors;
  }

  /// Validate customer form data
  static Map<String, String?> validateCustomerForm({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    Map<String, String?> errors = {};

    if (name.trim().isEmpty) {
      errors['name'] = 'Nama tidak boleh kosong';
    }

    if (email.trim().isEmpty) {
      errors['email'] = 'Email tidak boleh kosong';
    } else if (!_isValidEmail(email)) {
      errors['email'] = 'Format email tidak valid';
    }

    if (phone.trim().isEmpty) {
      errors['phone'] = 'Nomor telepon tidak boleh kosong';
    } else if (!_isValidPhone(phone)) {
      errors['phone'] = 'Format nomor telepon tidak valid';
    }

    if (address.trim().isEmpty) {
      errors['address'] = 'Alamat tidak boleh kosong';
    }

    return errors;
  }

  /// Check if email format is valid
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Check if phone format is valid (Indonesian phone number)
  static bool _isValidPhone(String phone) {
    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Indonesian phone number should start with 8 or country code
    if (cleanPhone.length < 10 || cleanPhone.length > 13) {
      return false;
    }

    // Should start with 8 (mobile) or country code 62
    return cleanPhone.startsWith('8') ||
           cleanPhone.startsWith('0');
  }
}

/// Service class for formatting data display
class FormatService {
  /// Format currency in Indonesian Rupiah
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Format duration in minutes to readable format
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} minggu lalu';
    } else {
      return '${(difference / 30).floor()} bulan lalu';
    }
  }

  /// Get category color based on category name
  static Color getCategoryColor(String category) {
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

  /// Get category icon based on category name
  static IconData getCategoryIcon(String category) {
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
