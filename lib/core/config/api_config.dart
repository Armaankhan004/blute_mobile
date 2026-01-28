class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // Onboarding
  static const String profile = '/onboarding/profile';
  static const String bank = '/onboarding/bank';
  static const String upload = '/files/upload';

  // User
  static const String me = '/users/me';

  // Subscriptions
  static const String plans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';

  // Gigs
  static const String gigs = '/gigs';
  static const String myBookings = '/gigs/my-bookings';
}
