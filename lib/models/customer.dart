import 'dart:convert';

class Customer {
  final int? id;
  final String name;
  final String contactMethod;
  final String contactValue;
  final String phone;
  final String address;
  final int? selectedServiceId; // Deprecated
  final String? selectedServiceName; // Deprecated
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> serviceCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.name,
    required this.contactMethod,
    required this.contactValue,
    this.phone = '',
    this.address = '',
    this.selectedServiceId,
    this.selectedServiceName,
    this.startDate,
    this.endDate,
    this.serviceCategories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_method': contactMethod,
      'contact_value': contactValue,
      'phone': phone,
      'address': address,
      'selected_service_id': selectedServiceId,
      'selected_service_name': selectedServiceName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'service_categories': jsonEncode(serviceCategories),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    // Handle backward compatibility
    String contactValue = map['contact_value'] ?? '';
    String contactMethod = map['contact_method'] ?? 'Email';

    if (contactValue.isEmpty && map['email'] != null && map['email'].toString().isNotEmpty) {
      contactValue = map['email'].toString();
      contactMethod = 'Email';
    }

    List<String> categories = [];
    if (map['service_categories'] != null) {
      try {
        categories = List<String>.from(jsonDecode(map['service_categories']));
      } catch (e) {
        // Fallback for empty or invalid json
        categories = [];
      }
    }

    return Customer(
      id: map['id'],
      name: map['name'],
      contactMethod: contactMethod,
      contactValue: contactValue,
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      selectedServiceId: map['selected_service_id'],
      selectedServiceName: map['selected_service_name'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      serviceCategories: categories,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? contactMethod,
    String? contactValue,
    String? phone,
    String? address,
    int? selectedServiceId,
    String? selectedServiceName,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? serviceCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      contactMethod: contactMethod ?? this.contactMethod,
      contactValue: contactValue ?? this.contactValue,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      selectedServiceName: selectedServiceName ?? this.selectedServiceName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
