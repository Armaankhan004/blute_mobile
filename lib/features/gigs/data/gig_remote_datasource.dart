import 'package:dio/dio.dart';
import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:blute_mobile/core/error/exceptions.dart';
import 'gig_model.dart';

class GigRemoteDataSource {
  final DioClient _dioClient;

  GigRemoteDataSource() : _dioClient = DioClient();

  // Fetch all available gigs (e.g. for a "Find Gigs" screen)
  Future<List<Gig>> getActiveGigs() async {
    try {
      final response = await _dioClient.dio.get(ApiConfig.gigs);
      final List<dynamic> data = response.data;
      return data.map((json) => Gig.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw ServerException(message: e.message ?? 'Failed to fetch gigs');
      }
      rethrow;
    }
  }

  // Fetch my bookings (Upcoming & Past)
  Future<List<GigBooking>> getMyBookings() async {
    try {
      final response = await _dioClient.dio.get(ApiConfig.myBookings);
      final List<dynamic> data = response.data;
      return data.map((json) => GigBooking.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw ServerException(message: e.message ?? 'Failed to fetch bookings');
      }
      rethrow;
    }
  }
}
