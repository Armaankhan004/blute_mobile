import 'package:dio/dio.dart';
import 'package:blute_mobile/core/config/api_config.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:blute_mobile/core/error/exceptions.dart';
import 'gig_model.dart';

class GigRemoteDataSource {
  final DioClient _dioClient;

  GigRemoteDataSource() : _dioClient = DioClient();

  // Fetch active gigs with optional search/filter/sort
  Future<List<Gig>> getActiveGigs({
    String? searchQuery,
    String? platform,
    String? location,
    String? sortBy,
    String? shift,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (platform != null) {
        queryParams['platform'] = platform;
      }
      if (location != null) {
        queryParams['location'] = location;
      }
      if (sortBy != null) {
        queryParams['sort_by'] = sortBy;
      }
      if (shift != null) {
        queryParams['shift'] = shift;
      }

      final response = await _dioClient.dio.get(
        ApiConfig.gigs,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      print('DEBUG: fetchGigs response type: ${response.data.runtimeType}');
      print('DEBUG: fetchGigs data: ${response.data}');
      if (response.data is! List) {
        throw ServerException(
          message: 'Unexpected response format: ${response.data}',
        );
      }
      final List<dynamic> data = response.data;
      return data.map((json) => Gig.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw ServerException(message: e.message ?? 'Failed to fetch gigs');
      }
      rethrow;
    }
  }

  // Fetch unique locations
  Future<List<String>> getLocations() async {
    try {
      final response = await _dioClient.dio.get('${ApiConfig.gigs}/locations');
      if (response.data is! List) {
        throw Exception('Unexpected response format for locations');
      }
      return List<String>.from(response.data);
    } catch (e) {
      print('ERROR: Failed to fetch locations: $e');
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

  // Book a gig
  Future<GigBooking> bookGig(String gigId, String slot) async {
    try {
      // The backend endpoint is POST /api/v1/gigs/{gig_id}/book?slot={slot}
      // It returns a GigBookingResponse
      final response = await _dioClient.dio.post(
        '${ApiConfig.gigs}/$gigId/book',
        queryParameters: {'slot': slot},
      );
      return GigBooking.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        // You might want to extract more specific error messages from e.response?.data['detail']
        final errorMsg =
            e.response?.data['detail'] ?? e.message ?? 'Failed to book gig';
        throw ServerException(message: errorMsg);
      }
      rethrow;
    }
  }
}
