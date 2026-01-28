import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';
import 'auth_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource() : _dioClient = DioClient();

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        // Handle specific Dio errors if needed, or rethrow
        // You might want to wrap this in a custom ServerException
        throw e; // For now rethrow
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.register,
        data: request.toJson(),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    try {
      await _dioClient.dio.post(
        ApiConfig.requestOtp,
        data: {'phone_number': phoneNumber},
      );
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConfig.verifyOtp,
        data: OtpVerifyRequest(phoneNumber: phoneNumber, otp: otp).toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }
}
