import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/features/auth/data/auth_remote_datasource.dart';
import 'package:blute_mobile/core/storage/token_storage.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  final TokenStorage _tokenStorage;

  AuthBloc()
    : _authRemoteDataSource = AuthRemoteDataSource(),
      _tokenStorage = TokenStorage(),
      super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRemoteDataSource.requestOtp(event.phoneNumber);
      emit(AuthOtpSent(phoneNumber: event.phoneNumber));
    } catch (e) {
      String message = 'Failed to send OTP';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          message = data['detail'] ?? e.message ?? 'An error occurred';
        } else if (data is String) {
          // Some backend errors might return plain text
          message = data;
        } else {
          message = e.message ?? 'An error occurred';
        }
      }
      emit(AuthError(message));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRemoteDataSource.verifyOtp(
        event.phoneNumber,
        event.otp,
      );

      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenStorage.saveToken(response.accessToken!);
        await _tokenStorage.saveRefreshToken(response.refreshToken!);
      } else {
        emit(const AuthError('Authentication failed: Missing tokens'));
        return;
      }

      if (response.exists) {
        emit(AuthAuthenticated());
      } else {
        // User is new (but now authenticated), navigate to registration
        emit(
          AuthNavigateToRegister(
            phoneNumber: response.phoneNumber ?? event.phoneNumber,
          ),
        );
      }
    } catch (e) {
      String message = 'Verification failed';
      if (e is DioException) {
        message =
            e.response?.data['detail'] ?? e.message ?? 'An error occurred';
      }
      emit(AuthError(message));
    }
  }
}
