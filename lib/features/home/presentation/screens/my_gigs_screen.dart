import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/gig_card.dart';

class MyGigsScreen extends StatelessWidget {
  const MyGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'My Gigs & Bookings',
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
              height: 50, // Slightly taller
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4), // Padding around the track
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
                  borderRadius: const BorderRadius.all(
                    Radius.circular(26),
                  ), // Inner radius slightly smaller
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
        body: const TabBarView(
          children: [_UpcomingGigsList(), _PastGigsList()],
        ),
      ),
    );
  }
}

class _UpcomingGigsList extends StatelessWidget {
  const _UpcomingGigsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        GigCard(
          companyName: 'blinkit',
          role: 'Delivery Partner',
          time: 'Today 5 PM',
          status: 'Registered',
          logoColor: Colors.amber,
        ),
        GigCard(
          companyName: 'Zepto',
          role: 'Delivery Partner',
          time: 'Today 7 PM',
          status: 'Registered',
          logoColor: Colors
              .purple, // Light purple in design, handled by logo widget possibly
        ),
        GigCard(
          companyName: 'Dunzo',
          role: 'Delivery Partner',
          time: 'Tomorrow 9 AM',
          status: 'Pending', // Status logic converts colors
          logoColor: Colors.green, // Dunzo green
        ),
        GigCard(
          companyName: 'Swiggy Genie',
          role: 'Delivery Partner',
          time: 'Today 6 PM',
          status: 'Registered',
          logoColor: Colors.orange,
        ),
        GigCard(
          companyName: 'Uber Eats',
          role: 'Delivery Partner',
          time: 'Today 8 PM',
          status: 'Active',
          logoColor: Colors.greenAccent,
        ),
      ],
    );
  }
}

class _PastGigsList extends StatelessWidget {
  const _PastGigsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        GigCard(
          companyName: 'blinkit',
          role: 'Delivery Partner',
          time: '29-12-2025(9 PM)',
          status: 'Completed',
          logoColor: Colors.amber,
        ),
        GigCard(
          companyName: 'Zepto',
          role: 'Delivery Partner',
          time: '29-12-2025(9 PM)',
          status: 'Completed',
          logoColor: Colors.purple,
        ),
        GigCard(
          companyName: 'Dunzo',
          role: 'Delivery Partner',
          time: '29-12-2025(9 PM)',
          status: 'Cancelled',
          logoColor: Colors.green,
        ),
        GigCard(
          companyName: 'Swiggy Instamart',
          role: 'Delivery Partner',
          time: '29-12-2025(9 PM)',
          status: 'In Progress', // Weird for "Past" but in design
          logoColor: Colors.orange,
        ),
      ],
    );
  }
}
