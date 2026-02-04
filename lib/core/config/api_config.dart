class ApiConfig {
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

  // User
  static const String me = '/driver/users/me';

  // Subscriptions
  static const String plans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';

  // Gigs
  static const String gigs = '/gigs/';
  static const String myBookings = '/gigs/my-bookings';

  // Config
  static const String config = '/config';
}
