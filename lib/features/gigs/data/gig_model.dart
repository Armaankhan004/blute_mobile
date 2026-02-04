import 'package:equatable/equatable.dart';

class Gig extends Equatable {
  final String id;
  final String platform;
  final String title;
  final String? description;
  final String? earnings;
  final String? location;
  final List<String> requirements;
  final DateTime startTime;
  final DateTime endTime;
  final int totalSlots;
  final int bookedSlots;
  final bool isActive;
  final bool isBookedByCurrentUser;

  const Gig({
    required this.id,
    required this.platform,
    required this.title,
    this.description,
    this.earnings,
    this.location,
    this.requirements = const [],
    required this.startTime,
    required this.endTime,
    required this.totalSlots,
    required this.bookedSlots,
    required this.isActive,
    this.isBookedByCurrentUser = false,
  });

  factory Gig.fromJson(Map<String, dynamic> json) {
    return Gig(
      id: json['id'],
      platform: json['platform'],
      title: json['title'],
      description: json['description'],
      earnings: json['earnings'],
      location: json['location'],
      requirements: json['requirements'] is List
          ? List<String>.from(json['requirements'])
          : [],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      totalSlots: json['total_slots'],
      bookedSlots: json['booked_slots'],
      isActive: json['is_active'] ?? true,
      isBookedByCurrentUser: json['is_booked_by_current_user'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, platform, title, startTime, endTime];
}

class GigBooking extends Equatable {
  final String id;
  final String userId;
  final String gigId;
  final String? slot; // The booked slot time (e.g., "5.00 PM")
  final String status;
  final DateTime createdAt;
  final Gig? gig;

  const GigBooking({
    required this.id,
    required this.userId,
    required this.gigId,
    this.slot,
    required this.status,
    required this.createdAt,
    this.gig,
  });

  factory GigBooking.fromJson(Map<String, dynamic> json) {
    return GigBooking(
      id: json['id'],
      userId: json['user_id'],
      gigId: json['gig_id'],
      slot: json['slot'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      gig: json['gig'] != null ? Gig.fromJson(json['gig']) : null,
    );
  }

  @override
  List<Object?> get props => [id, userId, gigId, status];
}
