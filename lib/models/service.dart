class Service {
  final int? id;
  final String name;
  // description field removed as requested
  final double price;
  final String durationPeriod; // Changed from int duration to String durationPeriod (1 minggu, 2 minggu, 1 bulan)
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    this.id,
    required this.name,
    required this.price,
    required this.durationPeriod,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_period': durationPeriod,
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
      durationPeriod: map['duration_period'] ?? map['duration']?.toString() ?? '1 minggu', // Backward compatibility
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Service copyWith({
    int? id,
    String? name,
    double? price,
    String? durationPeriod,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      durationPeriod: durationPeriod ?? this.durationPeriod,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
