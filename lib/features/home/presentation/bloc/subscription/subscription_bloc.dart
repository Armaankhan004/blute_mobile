import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  // Keeping plans data here for now, could be in a repository
  final List<Map<String, dynamic>> plans = [
    {'coins': 10, 'price': 100.00},
    {'coins': 20, 'price': 200.00},
    {'coins': 50, 'price': 500.00},
  ];

  int _selectedPlanIndex = -1;

  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<SelectSubscriptionPlan>(_onSelectSubscriptionPlan);
    on<ProcessSubscriptionPayment>(_onProcessSubscriptionPayment);
  }

  void _onSelectSubscriptionPlan(
    SelectSubscriptionPlan event,
    Emitter<SubscriptionState> emit,
  ) {
    _selectedPlanIndex = event.planIndex;
    emit(SubscriptionPlanSelected(_selectedPlanIndex));
  }

  Future<void> _onProcessSubscriptionPayment(
    ProcessSubscriptionPayment event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (_selectedPlanIndex == -1) {
      emit(const SubscriptionError('Please select a subscription plan'));
      // Reset to initial or keep selection state if meaningful (here re-emitting last valid or just error)
      // Actually we want to show error but keep selection?
      // Simplified: Just emit error. UI handles showing snackbar.
      return;
    }

    emit(SubscriptionPaymentLoading());

    // Stimulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock success
    final coins = plans[_selectedPlanIndex]['coins'] as int;
    emit(SubscriptionPaymentSuccess(coins));
  }
}
