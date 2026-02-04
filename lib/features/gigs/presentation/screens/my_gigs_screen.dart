import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/gig_card.dart';
import 'package:blute_mobile/features/gigs/data/gig_remote_datasource.dart';
import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:intl/intl.dart';

class MyGigsScreen extends StatefulWidget {
  const MyGigsScreen({super.key});

  @override
  State<MyGigsScreen> createState() => _MyGigsScreenState();
}

class _MyGigsScreenState extends State<MyGigsScreen> {
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();
  List<GigBooking> _upcoming = [];
  List<GigBooking> _past = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final bookings = await _gigDataSource.getMyBookings();
      final now = DateTime.now();

      final upcoming = <GigBooking>[];
      final past = <GigBooking>[];

      for (var booking in bookings) {
        // Safe check if gig is null
        if (booking.gig == null) continue;

        final isPast =
            booking.gig!.endTime.isBefore(now) || booking.status == 'CANCELLED';

        if (isPast) {
          past.add(booking);
        } else {
          upcoming.add(booking);
        }
      }

      // Sort: Upcoming (nearest first), Past (most recent first)
      upcoming.sort((a, b) => a.gig!.startTime.compareTo(b.gig!.startTime));
      past.sort((a, b) => b.gig!.startTime.compareTo(a.gig!.startTime));

      if (mounted) {
        setState(() {
          _upcoming = upcoming;
          _past = past;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'My Gigs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(26)),
                  color: AppColors.primary,
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchBookings,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _GigList(bookings: _upcoming, onRefresh: _fetchBookings),
                  _GigList(bookings: _past, onRefresh: _fetchBookings),
                ],
              ),
      ),
    );
  }
}

class _GigList extends StatelessWidget {
  final List<GigBooking> bookings;
  final Future<void> Function() onRefresh;

  const _GigList({required this.bookings, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text('No gigs found')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final gig = booking.gig!;

          // Format time display
          String timeDisplay;
          final now = DateTime.now();
          final isToday =
              gig.startTime.year == now.year &&
              gig.startTime.month == now.month &&
              gig.startTime.day == now.day;

          final timeFormat = DateFormat('h a'); // 5 PM
          final dateFormat = DateFormat('dd-MM-yyyy');

          if (isToday) {
            timeDisplay = 'Today ${timeFormat.format(gig.startTime)}';
          } else {
            timeDisplay =
                '${dateFormat.format(gig.startTime)}(${timeFormat.format(gig.startTime)})';
          }

          // Map platform to color (Simple logic for now)
          Color logoColor = Colors.blue;
          final platform = gig.platform.toLowerCase();
          if (platform.contains('blinkit'))
            logoColor = Colors.amber;
          else if (platform.contains('zepto'))
            logoColor = Colors.blue;
          else if (platform.contains('dunzo'))
            logoColor = Colors.green;
          else if (platform.contains('swiggy'))
            logoColor = Colors.orange;
          else if (platform.contains('uber'))
            logoColor = Colors.greenAccent;

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/slot-details', arguments: gig);
            },
            child: GigCard(
              companyName: gig.platform,
              role: gig.title,
              time: timeDisplay,
              status: booking.status,
              logoColor: logoColor,
            ),
          );
        },
      ),
    );
  }
}
