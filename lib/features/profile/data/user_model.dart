class UserResponse {
  final String id;
  final String? email;
  final String? phoneNumber;
  final bool isVerified;
  final ProfileResponse? profile;
  final String referralCode;
  final int subscriptionCoins;
  final int earnedCoins;
  final int gigsCompleted;
  final int monthlyGigsCount;
  final int monthlyBookedCount;
  final int monthlyCompletedCount;
  final int monthlyCancelledCount;

  UserResponse({
    required this.id,
    this.email,
    this.phoneNumber,
    this.isVerified = false,
    this.profile,
    required this.referralCode,
    this.subscriptionCoins = 0,
    this.earnedCoins = 0,
    this.gigsCompleted = 0,
    this.monthlyGigsCount = 0,
    this.monthlyBookedCount = 0,
    this.monthlyCompletedCount = 0,
    this.monthlyCancelledCount = 0,
  });

  // Helper to get total coins
  int get totalCoins => subscriptionCoins + earnedCoins;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'] ?? false,
      profile: json['profile'] != null
          ? ProfileResponse.fromJson(json['profile'])
          : null,
      referralCode: json['referral_code'] ?? '',
      subscriptionCoins: json['subscription_coins'] ?? 0,
      earnedCoins: json['earned_coins'] ?? 0,
      gigsCompleted: json['gigs_completed'] ?? 0,
      monthlyGigsCount: json['monthly_gigs_count'] ?? 0,
      monthlyBookedCount: json['monthly_booked_count'] ?? 0,
      monthlyCompletedCount: json['monthly_completed_count'] ?? 0,
      monthlyCancelledCount: json['monthly_cancelled_count'] ?? 0,
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
