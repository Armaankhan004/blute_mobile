part of 'subscription_bloc.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionPlanSelected extends SubscriptionState {
  final int selectedPlanIndex;
  const SubscriptionPlanSelected(this.selectedPlanIndex);

  @override
  List<Object> get props => [selectedPlanIndex];
}

class SubscriptionPaymentLoading extends SubscriptionState {}

class SubscriptionPaymentSuccess extends SubscriptionState {
  final int coinsEarned;
  const SubscriptionPaymentSuccess(this.coinsEarned);

  @override
  List<Object> get props => [coinsEarned];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}
