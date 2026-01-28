part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class SelectSubscriptionPlan extends SubscriptionEvent {
  final int planIndex;
  const SelectSubscriptionPlan(this.planIndex);

  @override
  List<Object> get props => [planIndex];
}

class ProcessSubscriptionPayment extends SubscriptionEvent {
  const ProcessSubscriptionPayment();
}
