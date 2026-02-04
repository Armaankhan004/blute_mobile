import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/di/injection_container.dart';

class UploadRemoteDataSource {
  final DioClient _dioClient;

  UploadRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? sl<DioClient>();

  Future<int> uploadScreenshots({
    required String partner,
    required DateTime date,
    required int deliveryCount,
    required List<String> filePaths,
  }) async {
    try {
      // Create list of multipart files
      List<MultipartFile> files = [];
      for (String filePath in filePaths) {
        String fileName = filePath.split('/').last;
        files.add(await MultipartFile.fromFile(filePath, filename: fileName));
      }

      FormData formData = FormData.fromMap({
        'partner': partner,
        'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'delivery_count': deliveryCount,
        'files': files,
      });

      final response = await _dioClient.dio.post(
        '/files/upload-screenshots',
        data: formData,
      );

      // Return coins earned from response
      return response.data['coins_earned'] ?? deliveryCount;
    } catch (e) {
      throw Exception('Failed to upload screenshots: $e');
    }
  }
}
