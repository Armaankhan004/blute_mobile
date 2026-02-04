import 'package:dio/dio.dart';
import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:blute_mobile/features/profile/data/models/partner_id_model.dart';
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

  Future<List<PartnerID>> getPartnerIDs() async {
    try {
      final response = await _dioClient.dio.get(ApiConfig.partnerIds);
      return (response.data as List)
          .map((json) => PartnerID.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw ServerException(
          message: e.message ?? 'Failed to fetch partner IDs',
        );
      }
      rethrow;
    }
  }

  Future<PartnerID> addPartnerID({
    required String platform,
    required String partnerIdCode,
    required String photoPath,
  }) async {
    try {
      String fileName = photoPath.split('/').last;
      FormData formData = FormData.fromMap({
        'platform': platform,
        'partner_id_code': partnerIdCode,
        'file': await MultipartFile.fromFile(photoPath, filename: fileName),
      });

      final response = await _dioClient.dio.post(
        ApiConfig.partnerIds,
        data: formData,
      );
      return PartnerID.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw ServerException(message: e.message ?? 'Failed to add partner ID');
      }
      rethrow;
    }
  }

  Future<void> deletePartnerID(String id) async {
    try {
      await _dioClient.dio.delete('${ApiConfig.partnerIds}/$id');
    } catch (e) {
      if (e is DioException) {
        throw ServerException(
          message: e.message ?? 'Failed to delete partner ID',
        );
      }
      rethrow;
    }
  }
}
