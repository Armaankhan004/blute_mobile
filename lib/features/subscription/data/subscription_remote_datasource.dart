import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:blute_mobile/core/error/exceptions.dart';
import 'package:dio/dio.dart';

class SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSource() : _dioClient = DioClient();

  Future<int> subscribe() async {
    try {
      final response = await _dioClient.dio.post(ApiConfig.subscribe);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['coins_added'] as int;
      } else {
        throw ServerException(message: 'Failed to process subscription');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMsg =
            e.response?.data['detail'] ?? e.message ?? 'Failed to subscribe';
        throw ServerException(message: errorMsg);
      }
      rethrow;
    }
  }
}
