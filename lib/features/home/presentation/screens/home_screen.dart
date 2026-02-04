import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/job_card.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/my_gigs_screen.dart';
import 'package:blute_mobile/features/profile/presentation/screens/profile_screen.dart';

import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:blute_mobile/features/gigs/data/gig_remote_datasource.dart';
import 'package:blute_mobile/core/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();
  final LocationService _locationService = LocationService();
  List<Gig> _gigs = [];
  bool _isLoading = true;
  String? _error;

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPlatform;
  String? _selectedLocation;
  String? _currentCity; // Auto-detected city
  String? _selectedSort;
  String? _selectedShift; // 'day' or 'night'
  double _selectedDistance = 50.0; // Default 50km radius
  Timer? _debounce;

  // Temporary filter state (for Apply button)
  String? _tempPlatform;
  String? _tempLocation;
  String? _tempSort;
  String? _tempShift;
  double _tempDistance = 50.0;

  final List<String> _platformOptions = [
    'blinkit',
    'zepto',
    'swiggy',
    'zomato',
    'dunzo',
    'uber',
  ];
  List<String> _locations = []; // Dynamic locations from API

  bool _hasInitiallyFetched = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _fetchLocations();
    _searchController.addListener(_onSearchChanged);
    _hasInitiallyFetched = true;
  }

  Future<void> _initLocation() async {
    final city = await _locationService.getCurrentCity();
    if (mounted) {
      setState(() {
        _currentCity = city;
        _selectedLocation = city; // Auto-select detected city
      });
      _fetchGigs(); // Fetch gigs after getting location
    } else {
      _fetchGigs(); // Fetch even if location fails
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh gigs when returning to this screen (e.g., after booking)
    if (_hasInitiallyFetched && _selectedIndex == 0) {
      _fetchGigs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid excessive API calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchGigs();
    });
  }

  Future<void> _fetchGigs() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final gigs = await _gigDataSource.getActiveGigs(
        searchQuery: _searchController.text,
        platform: _selectedPlatform,
        location: _selectedLocation,
        sortBy: _selectedSort,
        shift: _selectedShift,
      );

      // Sort: available gigs first, disabled (booked/full) last
      gigs.sort((a, b) {
        final aDisabled =
            a.isBookedByCurrentUser || (a.bookedSlots >= a.totalSlots);
        final bDisabled =
            b.isBookedByCurrentUser || (b.bookedSlots >= b.totalSlots);

        if (aDisabled == bDisabled) return 0;
        return aDisabled ? 1 : -1; // Available first
      });

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

  Future<void> _fetchLocations() async {
    // In a real app, this would fetch from backend
    // For now, we simulate some popular cities + current city
    final cities = {
      'Bangalore',
      'Mumbai',
      'Delhi',
      'Hyderabad',
      'Chennai',
      'Pune',
    };
    if (_currentCity != null) {
      cities.add(_currentCity!);
    }
    if (mounted) {
      setState(() {
        _locations = cities.toList()..sort();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getLogoColor(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('swiggy')) return Colors.orange;
    if (p.contains('zomato')) return Colors.red;
    if (p.contains('uber')) return Colors.black;
    if (p.contains('blinkit')) return Colors.yellow.shade700;
    if (p.contains('zepto')) return Colors.deepPurple;
    if (p.contains('dunzo')) return const Color(0xFF00FF00); // Dunzo green
    return AppColors.primary;
  }

  void _showSortFilter(BuildContext context) {
    // Initialize temp values with current selections
    _tempPlatform = _selectedPlatform;
    _tempLocation = _selectedLocation;
    _tempSort = _selectedSort;
    _tempShift = _selectedShift;
    _tempDistance = _selectedDistance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Apply Button on Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedPlatform = _tempPlatform;
                              _selectedLocation = _tempLocation;
                              _selectedSort = _tempSort;
                              _selectedShift = _tempShift;
                              _selectedDistance = _tempDistance;
                            });
                            Navigator.pop(context);
                            _fetchGigs();
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Platform Filter Section
                    const Text(
                      'Platform',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _platformOptions.map((platform) {
                        final isSelected = _tempPlatform == platform;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _tempPlatform = isSelected ? null : platform;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              platform.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Location Filter Section
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locations.map((location) {
                        final isSelected = _tempLocation == location;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _tempLocation = isSelected ? null : location;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              location,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Distance Filter Section
                    const Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _tempDistance,
                            min: 10,
                            max: 100,
                            divisions: 18,
                            activeColor: AppColors.primary,
                            label: '${_tempDistance.round()} km',
                            onChanged: (value) {
                              setModalState(() {
                                _tempDistance = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            '${_tempDistance.round()} km',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Shift Filter Section
                    const Text(
                      'Shift',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('Day Shift'),
                      value: 'day',
                      groupValue: _tempShift,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (String? value) {
                        setModalState(() {
                          _tempShift = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Night Shift'),
                      value: 'night',
                      groupValue: _tempShift,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (String? value) {
                        setModalState(() {
                          _tempShift = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Earnings Sort Section
                    const Text(
                      'Earnings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: const Text('High to Low'),
                      value: 'earnings_desc',
                      groupValue: _tempSort,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (String? value) {
                        setModalState(() {
                          _tempSort = value;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Low to High'),
                      value: 'earnings_asc',
                      groupValue: _tempSort,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (String? value) {
                        setModalState(() {
                          _tempSort = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topDemands = _gigs
        .where((gig) {
          if (gig.totalSlots == 0) return false;
          final progress = gig.bookedSlots / gig.totalSlots;
          return progress >= 0.3; // Show gigs with 30%+ booked
        })
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary, size: 20),
                  const SizedBox(width: 4),
                  DropdownButton<String>(
                    value: _selectedLocation,
                    hint: Text(
                      _currentCity ?? 'Select City',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                    underline: SizedBox(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                        _fetchGigs();
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Cities'),
                      ),
                      ..._locations.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
              centerTitle: false,
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
                : RefreshIndicator(
                    onRefresh: () async {
                      await _fetchGigs();
                      await _fetchLocations();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search jobs near you',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _fetchGigs();
                                      },
                                    )
                                  : null,
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
                                  final fillPercentage = gig.totalSlots > 0
                                      ? gig.bookedSlots / gig.totalSlots
                                      : 0.0;
                                  final isFull =
                                      gig.bookedSlots >= gig.totalSlots;
                                  final isAlmostFull = fillPercentage >= 0.7;
                                  final isHighDemand = fillPercentage >= 0.5;
                                  final isFillingFast = fillPercentage >= 0.3;

                                  final String badgeText;
                                  final Color badgeColor;

                                  if (isFull) {
                                    badgeText = 'Full';
                                    badgeColor = Colors.red;
                                  } else if (isAlmostFull) {
                                    badgeText = 'Almost Full';
                                    badgeColor = const Color(
                                      0xFFFF9800,
                                    ); // Orange
                                  } else if (isHighDemand) {
                                    badgeText = 'High Demand';
                                    badgeColor = const Color(
                                      0xFF6200EE,
                                    ); // Purple
                                  } else if (isFillingFast) {
                                    badgeText = 'Filling Fast';
                                    badgeColor = const Color(
                                      0xFFFF9800,
                                    ); // Orange
                                  } else {
                                    badgeText = 'Available';
                                    badgeColor = Colors.green;
                                  }

                                  // Check if disabled
                                  final isDisabled =
                                      gig.isBookedByCurrentUser || isFull;

                                  // Brand-specific colors
                                  Color brandBgColor = Colors.grey.shade100;
                                  Color brandBorderColor = Colors.blue;
                                  Color brandTextColor = Colors.black;

                                  final platform = gig.platform.toLowerCase();
                                  if (platform.contains('blinkit')) {
                                    brandBgColor = const Color(0xFFFFC107);
                                    brandBorderColor = const Color(0xFF2196F3);
                                    brandTextColor = Colors.black;
                                  } else if (platform.contains('zepto')) {
                                    brandBgColor = Colors.grey.shade100;
                                    brandBorderColor = Colors.transparent;
                                    brandTextColor = const Color(0xFF6200EE);
                                  }

                                  return Opacity(
                                    opacity: isDisabled ? 0.6 : 1.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: badgeColor,
                                            width: 2,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Badge
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.bolt,
                                                  color: badgeColor,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  badgeText,
                                                  style: TextStyle(
                                                    color: badgeColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Logo
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: brandBgColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: brandBorderColor,
                                                  width: 2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                gig.platform.toLowerCase(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: brandTextColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Slots Filled Text
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '${gig.bookedSlots}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '/${gig.totalSlots} ',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: 'Slots Filled',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Progress Bar
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: fillPercentage,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF6200EE)),
                                                minHeight: 6,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Book Slot Button
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: isDisabled
                                                    ? null
                                                    : () async {
                                                        await Navigator.pushNamed(
                                                          context,
                                                          '/slot-details',
                                                          arguments: gig,
                                                        );
                                                        // Refresh gigs after returning from details
                                                        _fetchGigs();
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF6200EE,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  disabledBackgroundColor:
                                                      Colors.grey.shade300,
                                                  disabledForegroundColor:
                                                      Colors.grey.shade600,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      isDisabled
                                                          ? (gig.isBookedByCurrentUser
                                                                ? 'Booked'
                                                                : 'Full')
                                                          : 'Book Slot',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (!isDisabled) ...[
                                                      const SizedBox(width: 4),
                                                      const Icon(
                                                        Icons.arrow_forward,
                                                        size: 14,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 24),

                          // Available Slots with Filters Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Available Slots',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showSortFilter(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.filter_list,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Filters',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _gigs.length,
                              itemBuilder: (context, index) {
                                final gig = _gigs[index];
                                final isDisabled =
                                    gig.isBookedByCurrentUser ||
                                    (gig.bookedSlots >= gig.totalSlots);
                                final availableSlots =
                                    gig.totalSlots - gig.bookedSlots;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16.0,
                                  ), // Add spacing between cards
                                  child: Opacity(
                                    opacity: isDisabled ? 0.5 : 1.0,
                                    child: JobCard(
                                      companyName: gig.platform,
                                      title: gig.title,
                                      salary:
                                          gig.earnings ?? 'Paid per delivery',
                                      location: gig.location ?? 'Bangalore',
                                      tags: gig.requirements.isNotEmpty
                                          ? gig.requirements
                                          : ['Delivery Job'],
                                      logoColor: _getLogoColor(gig.platform),
                                      status: isDisabled
                                          ? (gig.isBookedByCurrentUser
                                                ? 'Booked'
                                                : 'Full')
                                          : null,
                                      slotsInfo:
                                          '$availableSlots/${gig.totalSlots} slots available',
                                      onTap: isDisabled
                                          ? null
                                          : () async {
                                              await Navigator.pushNamed(
                                                context,
                                                '/slot-details',
                                                arguments: gig,
                                              );
                                              // Refresh gigs after returning from details
                                              _fetchGigs();
                                            },
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
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
