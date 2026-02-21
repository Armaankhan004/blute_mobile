import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:blute_mobile/features/gigs/data/gig_remote_datasource.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isBooking = false;
  final GigRemoteDataSource _gigDataSource = GigRemoteDataSource();

  Future<void> _confirmBooking(Gig gig, String slot) async {
    setState(() {
      _isBooking = true;
    });

    try {
      await _gigDataSource.bookGig(gig.id, slot);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/booking-success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Gig gig = args['gig'];
    final String selectedSlot = args['slot'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm Booking',
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
            _buildSectionSubtitle('Selected Slot'),
            Text(selectedSlot),
            const Divider(height: 32),
            _buildSectionSubtitle('Reporting Time'),
            Text(_formatReportingTime(selectedSlot)),
            const Divider(height: 32),
            _buildSectionSubtitle('Reporting Location'),
            Text('${gig.location ?? 'Various Locations'}${gig.state != null ? ', ${gig.state}' : ''}'),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: _isBooking
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Confirm Booking',
                      icon: Icons.arrow_forward,
                      onPressed: () => _confirmBooking(gig, selectedSlot),
                    ),
            ),
          ],
        ),
      ),
    );
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
      // Replace '.' with ':' for standard parsing if needed, but DateFormat can handle custom patterns
      // Pattern matching "h.mm a" based on SlotSelectionScreen
      final format = DateFormat('h.mm a');
      final dt = format.parse(slotTime);

      // We need a full DateTime to subtract duration, but parse gives us 1970-01-01
      // That's fine for time calculation
      final reportingDt = dt.subtract(const Duration(minutes: 30));
      return format.format(reportingDt);
    } catch (e) {
      // Fallback if parsing fails
      return "$slotTime (30 mins prior)";
    }
  }
}
