class Customer {
  final int? id;
  final String name;
  final String? email; // Made nullable for backward compatibility
  final String contactMethod;
  final String contactValue;
  final String phone;
  final String address; // Made optional for minimal form
  final int? selectedServiceId; // ID layanan yang dipilih pelanggan
  final String? selectedServiceName; // Nama layanan yang dipilih (untuk backward compatibility)
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.name,
    this.email, // Nullable
    required this.contactMethod,
    required this.contactValue,
    this.phone = '',
    this.address = '', // Made optional with default empty string
    this.selectedServiceId, // ID layanan yang dipilih
    this.selectedServiceName, // Nama layanan yang dipilih
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact_method': contactMethod,
      'contact_value': contactValue,
      'phone': phone,
      'address': address,
      'selected_service_id': selectedServiceId,
      'selected_service_name': selectedServiceName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'], // Can be null now
      contactMethod: map['contact_method'] ?? 'Email',
      contactValue: map['contact_value'] ?? map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      selectedServiceId: map['selected_service_id'],
      selectedServiceName: map['selected_service_name'],
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
