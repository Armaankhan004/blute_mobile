import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/home/presentation/widgets/job_card.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/my_gigs_screen.dart';
import 'package:blute_mobile/features/contests/presentation/screens/contest_details_screen.dart';
import 'package:blute_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:intl/intl.dart';

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
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();
  final LocationService _locationService = LocationService();
  List<Gig> _gigs = [];
  bool _isLoading = true;
  String? _error;

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedPlatforms = [];
  String? _selectedCity; // Top-left city selection
  List<String> _selectedLocations = []; // Area selection from filters
  String? _currentCity; // Auto-detected city
  String? _selectedSort;
  String? _selectedShift; // 'day' or 'night'
  DateTime? _selectedDate;
  double _selectedDistance = 50.0; // Default 50km radius
  String? _selectedDemand; // 'high_demand', 'filling_fast', 'almost_full'
  Timer? _debounce;

  // Temporary filter state (for Apply button)
  List<String> _tempPlatforms = [];
  List<String> _tempLocations = [];
  String? _tempSort;
  String? _tempShift;
  DateTime? _tempDate;
  double _tempDistance = 50.0;
  String? _tempDemand;

  List<String> _platformOptions = []; // Dynamic platforms from API
  List<String> _locations = []; // Dynamic locations (Areas) from API
  final List<String> _cityOptions = [
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Chennai',
    'Hyderabad',
    'Pune',
  ];

  bool _hasInitiallyFetched = false;

  // Search Hint Animation
  int _currentHintIndex = 0;
  final List<String> _searchHints = [
    'Search "Zepto"',
    'Search area',
    'Search "560001"',
    'Search jobs near you',
    'Search "Swiggy"',
    'Search "MG Road"',
    'Search pincode',
    'Search "FirstClub"',
    'Search "Blinkit"',
    'Search "Zomato"',
  ];
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _startHintTimer();
    _initLocation();
    _fetchPlatforms();
    _fetchLocations();
    _hasInitiallyFetched = true;
  }

  void _startHintTimer() {
    _hintTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
        });
      }
    });
  }

  Future<void> _initLocation() async {
    final city = await _locationService.getCurrentCity();
    if (mounted) {
      setState(() {
        _currentCity = city;
        // Auto-select detected city if it matches our supported list, else default to Bangalore
        if (_cityOptions.contains(city)) {
          _selectedCity = city;
        } else {
          _selectedCity = 'Bangalore';
        }
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
    _hintTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchGigs() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      var gigs = await _gigDataSource.getActiveGigs(
        searchQuery: _searchController.text,
        platform: _selectedPlatforms,
        // If specific areas (_selectedLocations) are chosen, use them.
        // Otherwise, use the selected city.
        location: _selectedLocations.isNotEmpty
            ? _selectedLocations
            : (_selectedCity != null ? [_selectedCity!] : null),
        sortBy: _selectedSort,
        shift: _selectedShift,
        date: _selectedDate,
      );

      // Apply local demand filter
      if (_selectedDemand != null) {
        gigs = gigs.where((gig) {
          final fillPercentage = gig.totalSlots > 0
              ? gig.bookedSlots / gig.totalSlots
              : 0.0;
          switch (_selectedDemand) {
            case 'high_demand':
              return fillPercentage >= 0.5 && fillPercentage < 0.8;
            case 'filling_fast':
              return fillPercentage >= 0.3 && fillPercentage < 0.5;
            case 'almost_full':
              return fillPercentage >= 0.8;
            default:
              return true;
          }
        }).toList();
      }

      // Filter out gigs already booked by the current user
      final filteredGigs = gigs
          .where((gig) => !gig.isBookedByCurrentUser)
          .toList();

      // Sort: available gigs first, disabled (full) last
      filteredGigs.sort((a, b) {
        final aFull = a.bookedSlots >= a.totalSlots;
        final bFull = b.bookedSlots >= b.totalSlots;

        if (aFull == bFull) return 0;
        return aFull ? 1 : -1; // Available first
      });

      if (mounted) {
        setState(() {
          _gigs = filteredGigs;
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

  Future<void> _fetchPlatforms() async {
    try {
      final platforms = await _gigDataSource.getPlatforms();
      if (mounted) {
        setState(() {
          _platformOptions = platforms;
        });
      }
    } catch (e) {
      print('DEBUG: Failed to fetch platforms: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _gigDataSource.getLocations();
      if (mounted) {
        setState(() {
          _locations = locations;
        });
      }
    } catch (e) {
      print('DEBUG: Failed to fetch locations: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Refresh profile whenever the profile tab is selected
    if (index == 3) {
      _profileKey.currentState?.fetchProfile();
    }
  }

  void _showSortFilter(BuildContext context) {
    // Initialize temp values with current selections
    _tempPlatforms = List.from(_selectedPlatforms);
    _tempLocations = List.from(_selectedLocations);
    _tempSort = _selectedSort;
    _tempShift = _selectedShift;
    _tempDistance = _selectedDistance;
    _tempDemand = _selectedDemand;
    _tempDate = _selectedDate;

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
                              _selectedPlatforms = _tempPlatforms;
                              _selectedLocations = _tempLocations;
                              _selectedSort = _tempSort;
                              _selectedShift = _tempShift;
                              _selectedDate = _tempDate;
                              _selectedDistance = _tempDistance;
                              _selectedDemand = _tempDemand;
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

                    // Date Filter Section
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _tempDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            _tempDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _tempDate != null
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _tempDate != null
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: _tempDate != null
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tempDate != null
                                  ? DateFormat('EEE, MMM d').format(_tempDate!)
                                  : 'Select Date',
                              style: TextStyle(
                                color: _tempDate != null
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_tempDate != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _tempDate = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
                        final isSelected = _tempPlatforms.contains(platform);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _tempPlatforms.remove(platform);
                              } else {
                                _tempPlatforms.add(platform);
                              }
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
                              platform, // Originally toUpperCase(), but backend data might differ
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
                      'Active Areas',
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
                        final isSelected = _tempLocations.contains(location);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _tempLocations.remove(location);
                              } else {
                                _tempLocations.add(location);
                              }
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
                    // Demand Status Filter Section
                    const Text(
                      'Demand Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            {'label': 'Filling Fast', 'value': 'filling_fast'},
                            {'label': 'High Demand', 'value': 'high_demand'},
                            {'label': 'Almost Full', 'value': 'almost_full'},
                          ].map((demand) {
                            final isSelected = _tempDemand == demand['value'];
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _tempDemand = isSelected
                                      ? null
                                      : demand['value'];
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
                                  demand['label']!,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            {'label': 'Day', 'value': 'day'},
                            {'label': 'Noon', 'value': 'noon'},
                            {'label': 'Evening', 'value': 'evening'},
                            {'label': 'Late Night', 'value': 'late_night'},
                          ].map((shift) {
                            final isSelected = _tempShift == shift['value'];
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _tempShift = isSelected
                                      ? null
                                      : shift['value'];
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
                                  shift['label']!,
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
                    value: _selectedCity,
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
                        _selectedCity = newValue;
                        _fetchGigs();
                      });
                    },
                    items: _cityOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              centerTitle: false,
              titleSpacing: 8, // Tighter top-left feel
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _fetchGigs(),
                            decoration: InputDecoration(
                              hintText: _searchHints[_currentHintIndex],
                              prefixIcon: IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: AppColors.primary,
                                ),
                                onPressed: _fetchGigs,
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
                                  final isAlmostFull = fillPercentage >= 0.8;
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
                                    badgeColor = AppColors.primary;
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
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.grey.shade200,
                                                  width: 2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(8),
                                              child: _buildPlatformLogo(
                                                gig.platform,
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
                                                    >(AppColors.primary),
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
                                                  backgroundColor:
                                                      AppColors.primary,
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
                                      status: isDisabled
                                          ? (gig.isBookedByCurrentUser
                                                ? 'Booked'
                                                : 'Full')
                                          : null,
                                      slotsInfo:
                                          '${gig.bookedSlots}/${gig.totalSlots} slots filled',
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
                                      date: DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(gig.startTime),
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
          ? const ContestDetailsScreen()
          : _selectedIndex == 2
          ? const MyGigsScreen()
          : ProfileScreen(key: _profileKey),
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
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Contests',
          ),
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

  Widget _buildPlatformLogo(String companyName) {
    final name = companyName.toLowerCase();
    String? assetPath;

    if (name.contains('swiggy')) {
      assetPath = 'assets/logos/swiggy.png';
    } else if (name.contains('zomato')) {
      assetPath = 'assets/logos/Zomato.png';
    } else if (name.contains('blinkit')) {
      assetPath = 'assets/logos/blinkit.png';
    } else if (name.contains('zepto')) {
      assetPath = 'assets/logos/zepto.png';
    } else if (name.contains('amazon')) {
      assetPath = 'assets/logos/amazonfresh.png';
    } else if (name.contains('firstclub')) {
      assetPath = 'assets/logos/firstclub.png';
    }

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            companyName.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          );
        },
      );
    }

    return Text(
      companyName.substring(0, 1).toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }
}
