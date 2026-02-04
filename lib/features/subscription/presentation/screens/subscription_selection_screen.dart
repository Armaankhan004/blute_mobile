import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/shared/widgets/custom_button.dart';
import 'package:blute_mobile/core/di/injection_container.dart' as di;
import 'package:blute_mobile/features/subscription/presentation/bloc/subscription/subscription_bloc.dart';

class SubscriptionSelectionScreen extends StatelessWidget {
  const SubscriptionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SubscriptionBloc>(),
      child: const _SubscriptionSelectionContent(),
    );
  }
}

class _SubscriptionSelectionContent extends StatelessWidget {
  const _SubscriptionSelectionContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SubscriptionPaymentSuccess) {
          _showPaymentSuccessDialog(context, state.coinsEarned);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Select Subscription'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                // Plans List
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  buildWhen: (previous, current) =>
                      current is SubscriptionPlanSelected ||
                      current is SubscriptionInitial,
                  builder: (context, state) {
                    int selectedIndex = -1;
                    if (state is SubscriptionPlanSelected) {
                      selectedIndex = state.selectedPlanIndex;
                    }

                    final bloc = context.read<SubscriptionBloc>();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloc.plans.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final plan = bloc.plans[index];
                        final isSelected = selectedIndex == index;
                        return GestureDetector(
                          onTap: () {
                            context.read<SubscriptionBloc>().add(
                              SelectSubscriptionPlan(index),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Monthly',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${plan['coins']} Coins',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹ ${plan['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Proceed Button
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Confirm Subscription',
                        isLoading: state is SubscriptionPaymentLoading,
                        onPressed: () {
                          context.read<SubscriptionBloc>().add(
                            const ProcessSubscriptionPayment(),
                          );
                        },
                        icon: Icons.arrow_forward,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment Successful',
                style: TextStyle(
                  color: Color(0xFF6200EE),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment for subscription is successful! You can now start booking slots now',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Ok',
                  onPressed: () {
                    Navigator.pop(ctx); // Close Payment Dialog
                    _showCongratulationsDialog(context, coinsEarned);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCongratulationsDialog(BuildContext context, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Congratulations!',
                style: TextStyle(
                  color: Color(0xFF6200EE),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations! You have earned $coinsEarned Blute coins and you can use it to book additional slots.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Ok',
                  onPressed: () {
                    Navigator.pop(ctx); // Close Congrats Dialog
                    Navigator.pop(context); // Go back to profile
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
