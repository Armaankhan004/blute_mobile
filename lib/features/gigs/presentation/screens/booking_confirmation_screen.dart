import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String selectedSlot =
        ModalRoute.of(context)?.settings.arguments as String? ?? '5.45 PM';

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
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'B', // Blinkit logo placeholder
                    style: TextStyle(
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
                      const Text(
                        'blinkit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Delivery Partner',
                        style: TextStyle(
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
                          _buildTag('Driver'),
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
            const Text(
              'Delivery Partner',
              style: TextStyle(color: Colors.black),
            ),
            const Divider(height: 32),
            _buildSectionTitle('Earnings'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Expected Earnings'),
            const Text('₹ 200 - ₹ 400/ delivery'),
            const Divider(height: 32),
            _buildSectionTitle('Slot/ Time Details'),
            const SizedBox(height: 8),
            _buildSectionSubtitle('Selected Slot'),
            Text(selectedSlot),
            const Divider(height: 32),
            _buildSectionSubtitle('Reporting Time'),
            const Text('5.30 PM'), // Mock reporting time
            const Divider(height: 32),
            _buildSectionSubtitle('Reporting Location'),
            const Text('blinkit - DarkStore, HSR Layout'),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Confirm Booking',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(context, '/booking-success');
                },
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
}
