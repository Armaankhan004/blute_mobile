import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';
import 'auth_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource() : _dioClient = DioClient();

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔵 LOGIN ATTEMPT');
      final response = await _dioClient.dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );
      print('✅ LOGIN SUCCESS');
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      print('❌ LOGIN ERROR: $e');
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      print('🔵 REGISTER ATTEMPT');
      final response = await _dioClient.dio.post(
        ApiConfig.register,
        data: request.toJson(),
      );
      print('✅ REGISTER SUCCESS');
      return response.data;
    } catch (e) {
      print('❌ REGISTER ERROR: $e');
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    try {
      print('🔵 REQUEST OTP');
      print('📱 Phone: "$phoneNumber"');
      print('🌐 URL: ${ApiConfig.requestOtp}');
      
      final response = await _dioClient.dio.post(
        ApiConfig.requestOtp,
        data: {'phone_number': phoneNumber},
      );
      
      print('✅ REQUEST OTP SUCCESS');
      print('📨 Response: ${response.data}');
    } catch (e) {
      print('❌ REQUEST OTP ERROR');
      if (e is DioException) {
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        if (e.response != null) {
          print('Status: ${e.response?.statusCode}');
          print('Data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<VerifyOtpResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      print('🔵 VERIFY OTP');
      print('📱 Phone: "$phoneNumber"');
      print('🔢 OTP: "$otp"');
      print('🌐 URL: ${ApiConfig.verifyOtp}');
      
      final requestData = {
        'phone_number': phoneNumber,
        'otp': otp,
      };
      print('📦 Request data: $requestData');
      print('📦 JSON: ${jsonEncode(requestData)}');
      
      final response = await _dioClient.dio.post(
        ApiConfig.verifyOtp,
        data: requestData,
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) {
            return status! < 500; // Don't throw on 4xx errors
          },
        ),
      );
      
      print('📨 Response status: ${response.statusCode}');
      print('📨 Response headers: ${response.headers}');
      print('📨 Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        print('✅ VERIFY OTP SUCCESS');
        return VerifyOtpResponse.fromJson(response.data);
      } else {
        print('❌ VERIFY OTP FAILED WITH STATUS ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'OTP verification failed: ${response.data}',
        );
      }
    } catch (e) {
      print('❌ VERIFY OTP EXCEPTION');
      if (e is DioException) {
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        if (e.response != null) {
          print('Status: ${e.response?.statusCode}');
          print('Data: ${e.response?.data}');
        } else {
          print('No response received - network error');
        }
      } else {
        print('Unknown error: $e');
      }
      rethrow;
    }
  }
}