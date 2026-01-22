import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    emit(AuthOtpSent(phoneNumber: event.phoneNumber));
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    emit(AuthAuthenticated());
  }
}
