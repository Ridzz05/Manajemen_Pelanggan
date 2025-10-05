class BusinessProfile {
  final int? id;
  final String businessName;
  final String businessDescription;
  final String businessLogo; // Path to logo image
  final String businessEmail;
  final String businessPhone;
  final String businessAddress;
  final String businessWebsite;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessProfile({
    this.id,
    required this.businessName,
    required this.businessDescription,
    required this.businessLogo,
    required this.businessEmail,
    required this.businessPhone,
    required this.businessAddress,
    required this.businessWebsite,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'business_description': businessDescription,
      'business_logo': businessLogo,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'business_address': businessAddress,
      'business_website': businessWebsite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'],
      businessName: map['business_name'],
      businessDescription: map['business_description'],
      businessLogo: map['business_logo'],
      businessEmail: map['business_email'],
      businessPhone: map['business_phone'],
      businessAddress: map['business_address'],
      businessWebsite: map['business_website'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BusinessProfile copyWith({
    int? id,
    String? businessName,
    String? businessDescription,
    String? businessLogo,
    String? businessEmail,
    String? businessPhone,
    String? businessAddress,
    String? businessWebsite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessLogo: businessLogo ?? this.businessLogo,
      businessEmail: businessEmail ?? this.businessEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      businessAddress: businessAddress ?? this.businessAddress,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Default profile for initialization
  factory BusinessProfile.defaultProfile() {
    return BusinessProfile(
      businessName: 'AWB Auto Workshop',
      businessDescription: 'Bengkel Mobil Terpercaya',
      businessLogo: '', // Empty for default logo
      businessEmail: 'info@awb-autoworkshop.com',
      businessPhone: '+62 812-3456-7890',
      businessAddress: 'Jl. Raya Bengkel No. 123, Jakarta',
      businessWebsite: 'www.awb-autoworkshop.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
