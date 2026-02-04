import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phoneNumber;

  const AuthOtpSent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthNavigateToRegister extends AuthState {
  final String phoneNumber;

  const AuthNavigateToRegister({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthGuest extends AuthState {}
