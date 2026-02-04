import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/features/gigs/data/gig_model.dart';
import 'package:intl/intl.dart';

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String? _selectedSlot;

  // Ideally this should be generated from gig.startTime and gig.endTime
  // For now we keep the mock slots but valid for the UI
  List<Map<String, dynamic>> _slots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generateSlots();
  }

  void _generateSlots() {
    final gig = ModalRoute.of(context)!.settings.arguments as Gig;
    final List<Map<String, dynamic>> slots = [];

    DateTime currentTime = gig.startTime;
    while (currentTime.isBefore(gig.endTime)) {
      // Format time as "5.00 PM"
      String formattedTime = DateFormat('h.mm a').format(currentTime);

      // Calculate isFull logic dynamically (for now just mock random or based on index)
      // Here we will just keep the first slot full logic if needed, or make all available
      // Since backend controls actual availability, UI availability could be mock or data driven
      // For now, let's make no slots full to allow booking testing
      bool isFull = false;

      slots.add({'time': formattedTime, 'isFull': isFull});

      // Increment by 45 minutes
      currentTime = currentTime.add(const Duration(minutes: 45));
    }

    setState(() {
      _slots = slots;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the Gig object from arguments
    final gig = ModalRoute.of(context)!.settings.arguments as Gig;

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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Text(
              "Gig: ${gig.title}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _slots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final slot = _slots[index];

                bool isFull = slot['isFull'];
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
                                : AppColors.primary.withValues(alpha: 0.5),
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
                          arguments: {'gig': gig, 'slot': _selectedSlot},
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
