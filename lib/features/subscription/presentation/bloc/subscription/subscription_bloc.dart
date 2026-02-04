import 'package:blute_mobile/features/subscription/data/subscription_remote_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRemoteDataSource _remoteDataSource;

  // Keeping plans data here for now, could be in a repository
  final List<Map<String, dynamic>> plans = [
    {'coins': 20, 'price': 0.00},
  ];

  int _selectedPlanIndex = 0;

  SubscriptionBloc({required SubscriptionRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource,
      super(SubscriptionPlanSelected(0)) {
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
      return;
    }

    emit(SubscriptionPaymentLoading());

    try {
      final coinsAdded = await _remoteDataSource.subscribe();
      emit(SubscriptionPaymentSuccess(coinsAdded));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
