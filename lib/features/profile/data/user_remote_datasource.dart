import 'package:dio/dio.dart';
import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'user_model.dart';
import 'package:blute_mobile/core/error/exceptions.dart';

class UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSource() : _dioClient = DioClient();

  Future<UserResponse> getUserProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConfig.me);
      return UserResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw ServerException(message: e.message ?? 'Failed to fetch profile');
      }
      rethrow;
    }
  }
}
