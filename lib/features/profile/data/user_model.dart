class UserResponse {
  final String id;
  final String? email;
  final String? phoneNumber;
  final bool isVerified;
  final ProfileResponse? profile;

  UserResponse({
    required this.id,
    this.email,
    this.phoneNumber,
    this.isVerified = false,
    this.profile,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'] ?? false,
      profile: json['profile'] != null
          ? ProfileResponse.fromJson(json['profile'])
          : null,
    );
  }
}

class ProfileResponse {
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? address;
  final String? locality;
  final String? educationQualification;

  ProfileResponse({
    this.firstName,
    this.lastName,
    this.dob,
    this.address,
    this.locality,
    this.educationQualification,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      firstName: json['first_name'],
      lastName: json['last_name'],
      dob: json['dob'],
      address: json['address'],
      locality: json['locality'],
      educationQualification: json['education_qualification'],
    );
  }
}
