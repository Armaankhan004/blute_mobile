import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/job_card.dart';
import 'package:blute_mobile/features/home/presentation/widgets/top_demand_card.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/my_gigs_screen.dart';
import 'package:blute_mobile/features/profile/presentation/screens/profile_screen.dart';

import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:blute_mobile/features/gigs/data/gig_remote_datasource.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();
  List<Gig> _gigs = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _filters = ['Distance', 'Salary', 'Shift', 'Skills'];

  @override
  void initState() {
    super.initState();
    _fetchGigs();
  }

  Future<void> _fetchGigs() async {
    try {
      final gigs = await _gigDataSource.getActiveGigs();
      if (mounted) {
        setState(() {
          _gigs = gigs;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getLogoColor(String platform) {
    platform = platform.toLowerCase();
    if (platform.contains('blinkit')) return Colors.amber;
    if (platform.contains('zepto')) return Colors.purple;
    if (platform.contains('dunzo')) return Colors.green;
    if (platform.contains('swiggy')) return Colors.orange;
    if (platform.contains('uber')) return Colors.black;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final topDemands = _gigs
        .where((gig) {
          if (gig.totalSlots == 0) return false;
          final progress = gig.bookedSlots / gig.totalSlots;
          return progress >= 0.7;
        })
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(
                'Home',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
              automaticallyImplyLeading: false,
            )
          : null,
      body: _selectedIndex == 0
          ? _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchGigs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search jobs near you',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((filter) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(
                                    filter,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  onDeleted: () {},
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide.none,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Top Demands (Dynamic)
                        if (topDemands.isNotEmpty) ...[
                          const Text(
                            'Top Demands',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: topDemands.map((gig) {
                                final double progress = gig.totalSlots > 0
                                    ? gig.bookedSlots / gig.totalSlots
                                    : 0.0;
                                return TopDemandCard(
                                  companyName: gig.platform,
                                  badgeText: progress > 0.8
                                      ? 'Filling Fast'
                                      : 'High Demand',
                                  badgeColor: progress > 0.8
                                      ? Colors.amber
                                      : Colors.orange,
                                  progress: progress,
                                  slotsFilled: gig.bookedSlots,
                                  totalSlots: gig.totalSlots,
                                  logoColor: _getLogoColor(gig.platform),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/slot-details',
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 24),

                        // Available Slots
                        const Text(
                          'Available Slots',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_gigs.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No gigs available right now"),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _gigs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final gig = _gigs[index];
                              return JobCard(
                                companyName: gig.platform,
                                title: gig.title,
                                salary:
                                    gig.earnings ??
                                    'Paid per delivery', // Default if null
                                location:
                                    gig.location ?? 'Bangalore', // Default
                                tags: gig.requirements.isNotEmpty
                                    ? gig.requirements
                                    : ['Delivery Job'],
                                logoColor: _getLogoColor(gig.platform),
                                badgeText:
                                    gig.bookedSlots > (gig.totalSlots * 0.8)
                                    ? 'Filling Fast'
                                    : null,
                              );
                            },
                          ),
                      ],
                    ),
                  )
          : _selectedIndex == 1
          ? const MyGigsScreen()
          : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'My Gigs',
          ), // Icon looked like a briefcase
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
