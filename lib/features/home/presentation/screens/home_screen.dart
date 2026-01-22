import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/job_card.dart';
import 'package:blute_mobile/features/home/presentation/widgets/top_demand_card.dart';
import 'package:blute_mobile/features/home/presentation/screens/my_gigs_screen.dart';
import 'package:blute_mobile/features/home/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _filters = [
    'Distance',
    'Salary',
    'Shift',
    'Skills', // Truncated in image, guessing
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
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
                        ), // Purple border in design
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                            onDeleted: () {}, // To show the icon
                            backgroundColor: AppColors.primary.withOpacity(
                              0.05,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide.none,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Demands
                  const Text(
                    'Top Demands',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TopDemandCard(
                          companyName: 'blinkit',
                          badgeText: 'Filling Fast',
                          badgeColor: Colors
                              .amber, // Not exactly purple/yellow mix but close enough
                          progress: 0.78,
                          slotsFilled: 78,
                          totalSlots: 100,
                          logoColor: Colors.amber,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/slot-details'),
                        ),
                        TopDemandCard(
                          companyName: 'zepto',
                          badgeText: 'Almost Full',
                          badgeColor: Colors.orange,
                          progress: 0.90,
                          slotsFilled: 90,
                          totalSlots: 100,
                          logoColor: Colors.purple.shade50,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/slot-details'),
                        ),
                        TopDemandCard(
                          companyName: 'swiggy',
                          badgeText: 'Filling Fast',
                          badgeColor: Colors.orange,
                          progress: 0.50,
                          slotsFilled: 50,
                          totalSlots: 100,
                          logoColor: Colors.orange.shade50,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/slot-details'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available Slots
                  const Text(
                    'Available Slots',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const JobCard(
                    companyName: 'blinkit',
                    title: 'Delivery Partner',
                    salary: 'Up to ₹20000 / month',
                    location: 'HSR Layout, Bangalore',
                    tags: [
                      '5-6 PM',
                      'Daily Payments',
                      'Delivery Job',
                      'Driver',
                    ],
                    logoColor: Colors.amber,
                    badgeText: 'Filling Fast',
                  ),
                  const JobCard(
                    companyName: 'Zepto',
                    title: 'Dark Store Executive',
                    salary: 'Up to ₹20000 / month',
                    location: 'HSR Layout, Bangalore',
                    tags: [
                      '5-6 PM',
                      'Daily Payments',
                      'Delivery Job',
                      'Driver',
                    ],
                    logoColor: Colors.white,
                  ),
                  const JobCard(
                    companyName: 'blinkit',
                    title: 'Delivery Partner',
                    salary: 'Up to ₹20000 / month',
                    location: 'HSR Layout, Bangalore',
                    tags: [
                      '5-6 PM',
                      'Daily Payments',
                      'Delivery Job',
                      'Driver',
                    ],
                    logoColor: Colors.amber,
                  ),
                  const JobCard(
                    companyName: 'blinkit',
                    title: 'Delivery Partner',
                    salary: 'Up to ₹20000 / month',
                    location: 'HSR Layout, Bangalore',
                    tags: [
                      '5-6 PM',
                      'Daily Payments',
                      'Delivery Job',
                      'Driver',
                    ],
                    logoColor: Colors.amber,
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
