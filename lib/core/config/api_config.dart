class ApiConfig {
  // For Android Emulator use 10.0.2.2, for iOS Simulator use localhost
  // If using a physical device, replace with your machine's LAN IP (e.g., 192.168.1.x)
  static const String baseUrl =
      'https://exemplificative-nonmodificatory-usha.ngrok-free.dev/api/v1';

  // Auth
  static const String login = '/driver/auth/login';
  static const String register = '/driver/auth/register';
  static const String refreshToken = '/driver/auth/refresh';
  static const String requestOtp = '/driver/auth/request-otp';
  static const String verifyOtp = '/driver/auth/verify-otp';

  // Onboarding
  static const String profile = '/driver/onboarding/profile';
  static const String bank = '/driver/onboarding/bank';
  static const String upload = '/driver/files/upload';
  static const String uploadScreenshots = '/driver/files/upload-screenshots';

  // User
  static const String me = '/driver/users/me';
  static const String partnerIds = '/driver/partner-ids/';

  // Subscriptions
  static const String plans = '/driver/subscriptions/plans';
  static const String subscribe = '/driver/subscriptions/subscribe';

  // Gigs
  static const String gigs = '/gigs';
  static const String myBookings = '/gigs/my-bookings';

  // Config
  static const String config = '/config';
}
