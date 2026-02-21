import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:blute_mobile/features/gigs/data/gig_remote_datasource.dart';
import 'package:intl/intl.dart';

class SlotDetailsScreen extends StatefulWidget {
  const SlotDetailsScreen({super.key});

  @override
  State<SlotDetailsScreen> createState() => _SlotDetailsScreenState();
}

class _SlotDetailsScreenState extends State<SlotDetailsScreen> {
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();
  Gig? _currentGig;
  String? _bookedSlot; // Store the booked slot time
  bool _hasBooking = false; // Track if user has ANY booking for this gig
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _fetchFreshGigData();
    }
  }

  Future<void> _fetchFreshGigData() async {
    // Get the initial gig object from arguments to get the ID
    final passedGig = ModalRoute.of(context)!.settings.arguments as Gig;

    try {
      // Fetch all gigs to get the fresh data for this specific gig
      final gigs = await _gigDataSource.getActiveGigs();
      final freshGig = gigs.firstWhere(
        (g) => g.id == passedGig.id,
        orElse: () => passedGig, // Fallback to passed gig if not found
      );

      // Always check if user has booked this gig (regardless of backend flag)
      // This catches all booking statuses: BOOKED, COMPLETED, CANCELLED
      String? bookedSlot;
      bool hasBooking = false;
      try {
        final bookings = await _gigDataSource.getMyBookings();
        final booking = bookings.firstWhere(
          (b) => b.gigId == freshGig.id,
          orElse: () => throw Exception('Booking not found'),
        );
        bookedSlot = booking.slot;
        hasBooking = true;
      } catch (e) {
        // No booking found, user can book
        print('No booking found for this gig: $e');
      }

      if (mounted) {
        setState(() {
          _currentGig = freshGig;
          _bookedSlot = bookedSlot;
          _hasBooking = hasBooking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _currentGig = passedGig; // Use passed gig as fallback
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading || _currentGig == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Viewing Slot Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Use the fresh gig data
    final gig = _currentGig!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Viewing Slot Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getLogoColor(gig.platform),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    gig.platform.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gig.platform,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gig.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag('Daily Payments'),
                          const SizedBox(width: 8),
                          _buildTag('Delivery Job'),
                          const SizedBox(width: 8),
                          if (gig.bookedSlots > gig.totalSlots * 0.8)
                            _buildTag('Filling Fast'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Gig/ Job Title'),
            const SizedBox(height: 8),
            Text(gig.title, style: const TextStyle(color: Colors.black)),
            const Divider(height: 32),
            _buildSectionTitle('Earnings'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Expected Earnings'),
            Text(gig.earnings ?? 'Paid per delivery'),
            const Divider(height: 32),
            _buildSectionTitle('Slot/ Time Details'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Date'),
            Text(DateFormat('MMMM dd, yyyy').format(gig.startTime)),
            const SizedBox(height: 16),
            _buildSectionSubtitle('Slots'),
            Text(
              '${DateFormat.jm().format(gig.startTime)} to ${DateFormat.jm().format(gig.endTime)}',
            ),
            const SizedBox(height: 16),
            _buildSectionSubtitle('Locations'),
            Text('${gig.location ?? 'Various Locations'}${gig.state != null ? ', ${gig.state}' : ''}'),
            const Divider(height: 32),
            _buildSectionTitle('Requirements'),
            const SizedBox(height: 16),
            if (gig.requirements.isNotEmpty)
              ...gig.requirements.map(
                (req) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(req),
                ),
              )
            else
              const Text('No specific requirements mentioned'),

            const SizedBox(height: 48),

            // Only show Book Slot button if no booking exists and slots available
            if (!_hasBooking && gig.bookedSlots < gig.totalSlots)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Book Slot',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/slot-selection',
                      arguments: gig, // Pass the gig object forward
                    );
                  },
                ),
              )
            else
              // Show booking details with reporting time
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasBooking
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasBooking
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasBooking ? Icons.check_circle : Icons.block,
                          color: _hasBooking ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _hasBooking
                                ? 'You have already booked this slot'
                                : 'This slot is fully booked',
                            style: TextStyle(
                              color: _hasBooking
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_hasBooking && _bookedSlot != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date:',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.blue.shade900,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(gig.startTime),
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Slot Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Slot Time:',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _bookedSlot!,
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Reporting Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reporting Time:',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.orange.shade900,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatReportingTime(_bookedSlot!),
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getLogoColor(String platform) {
    platform = platform.toLowerCase();
    if (platform.contains('blinkit')) return Colors.amber;
    if (platform.contains('zepto')) return Colors.blue;
    if (platform.contains('dunzo')) return Colors.green;
    if (platform.contains('swiggy')) return Colors.orange;
    if (platform.contains('uber')) return Colors.black;
    return Colors.blue;
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  String _formatReportingTime(String slotTime) {
    try {
      // Expected format: "5.00 PM"
      final format = DateFormat('h.mm a');
      final dt = format.parse(slotTime);

      // Subtract 30 minutes for reporting time
      final reportingDt = dt.subtract(const Duration(minutes: 30));
      return format.format(reportingDt);
    } catch (e) {
      // Fallback if parsing fails
      return "$slotTime (30 mins prior)";
    }
  }
}
