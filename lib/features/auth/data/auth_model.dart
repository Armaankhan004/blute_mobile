class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'phone_number': phoneNumber,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
}

class OtpVerifyRequest {
  final String phoneNumber;
  final String otp;

  OtpVerifyRequest({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() => {'phone_number': phoneNumber, 'otp': otp};
}
