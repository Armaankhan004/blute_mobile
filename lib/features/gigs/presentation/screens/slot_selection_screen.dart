import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String? _selectedSlot;

  final List<Map<String, dynamic>> _slots = [
    {'time': '5.00 PM', 'isFull': false},
    {'time': '5.45 PM', 'isFull': false},
    {'time': '6.30 PM', 'isFull': false},
    {'time': '7.15 PM', 'isFull': false},
    {'time': '8.00 PM', 'isFull': false},
    {'time': '8.45 PM', 'isFull': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Slot To Book',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _slots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final slot = _slots[index];
                /* Mocking one slot as full to match design example if needed, 
                   but list above has all false. Let's make first one full programmatically 
                   to demonstrate the UI state */
                bool isFull =
                    index == 0; // Mocking 5.00 PM as full as per design variant
                bool isSelected = _selectedSlot == slot['time'];

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 0,
                  ), // Separator handles spacing
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isFull
                          ? null
                          : () {
                              setState(() {
                                _selectedSlot = slot['time'];
                              });
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isFull
                              ? Colors.grey.shade100
                              : isSelected
                              ? Colors.purple.shade50
                              : Colors.white,
                          border: Border.all(
                            color: isFull
                                ? Colors.grey.shade300
                                : isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.5),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              slot['time'],
                              style: TextStyle(
                                color: isFull
                                    ? Colors.grey
                                    : isSelected
                                    ? AppColors.primary
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isFull) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SLOT FULL',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _selectedSlot == null
                    ? 'Select a Slot'
                    : 'Book Slot ($_selectedSlot)',
                icon: Icons.arrow_forward,
                onPressed: _selectedSlot == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/booking-confirmation',
                          arguments: _selectedSlot,
                        );
                      },
                // Need to handle disabled state in CustomButton or wrap here
                // CustomButton likely doesn't support disabled styling automatically based on my memory
                // But passing null onPressed usually disables ElevatedButton.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
