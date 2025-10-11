class Service {
  final int? id;
  final String name;
  // description field removed as requested
  final double price;
  final DateTime? startDate; // Start date of service period
  final DateTime? endDate;   // End date of service period
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    this.id,
    required this.name,
    required this.price,
    this.startDate,
    this.endDate,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Service copyWith({
    int? id,
    String? name,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if service is currently active
  bool get isActive {
    final now = DateTime.now();
    if (startDate == null || endDate == null) return false;
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }

  // Helper method to get duration in days
  int? get durationInDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays;
  }
}
