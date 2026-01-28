import 'package:dio/dio.dart';
import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:file_picker/file_picker.dart';
import 'onboarding_model.dart';

class OnboardingRemoteDataSource {
  final DioClient _dioClient;

  OnboardingRemoteDataSource() : _dioClient = DioClient();

  Future<void> updateProfile(ProfileRequest request) async {
    try {
      await _dioClient.dio.post(ApiConfig.profile, data: request.toJson());
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<void> updateBankDetails(BankRequest request) async {
    try {
      await _dioClient.dio.post(ApiConfig.bank, data: request.toJson());
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }

  Future<void> uploadDocument(PlatformFile file, String fileType) async {
    try {
      String fileName = file.name;
      String filePath = file.path!; // Note: web might need bytes

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'file_type': fileType, // 'AADHAR', 'PAN', etc.
      });

      await _dioClient.dio.post(ApiConfig.upload, data: formData);
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      rethrow;
    }
  }
}
