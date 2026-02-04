class PartnerID {
  final String id;
  final String userId;
  final String platform;
  final String partnerIdCode;
  final String? idPhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PartnerID({
    required this.id,
    required this.userId,
    required this.platform,
    required this.partnerIdCode,
    this.idPhotoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory PartnerID.fromJson(Map<String, dynamic> json) {
    return PartnerID(
      id: json['id'],
      userId: json['user_id'],
      platform: json['platform'],
      partnerIdCode: json['partner_id_code'],
      idPhotoUrl: json['id_photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform,
      'partner_id_code': partnerIdCode,
      'id_photo_url': idPhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
