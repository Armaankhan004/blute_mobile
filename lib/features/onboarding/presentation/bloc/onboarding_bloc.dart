import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:blute_mobile/features/onboarding/data/onboarding_remote_datasource.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRemoteDataSource _repository;

  OnboardingBloc()
    : _repository = OnboardingRemoteDataSource(),
      super(OnboardingInitial()) {
    on<SubmitProfileEvent>(_onSubmitProfile);
    on<SubmitBankEvent>(_onSubmitBank);
    on<UploadDocumentsEvent>(_onUploadDocuments);
  }

  Future<void> _onSubmitProfile(
    SubmitProfileEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      await _repository.updateProfile(event.profileData);
      emit(const OnboardingSuccess('profile'));
    } catch (e) {
      String message = 'Profile update failed';
      if (e is DioException) {
        final detail = e.response?.data['detail'];
        if (detail is List) {
          // Handle validation errors (List)
          message = detail.map((e) => e['msg'] ?? e.toString()).join('\n');
        } else if (detail is String) {
          message = detail;
        } else {
          message = e.message ?? 'An error occurred';
        }
      }
      emit(OnboardingError(message));
    }
  }

  Future<void> _onSubmitBank(
    SubmitBankEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      await _repository.updateBankDetails(event.bankData);
      emit(const OnboardingSuccess('bank'));
    } catch (e) {
      String message = 'Bank details update failed';
      if (e is DioException) {
        final detail = e.response?.data['detail'];
        if (detail is List) {
          message = detail.map((e) => e['msg'] ?? e.toString()).join('\n');
        } else if (detail is String) {
          message = detail;
        } else {
          message = e.message ?? 'An error occurred';
        }
      }
      emit(OnboardingError(message));
    }
  }

  Future<void> _onUploadDocuments(
    UploadDocumentsEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      for (var doc in event.documents) {
        await _repository.uploadDocument(doc.file, doc.fileType);
      }
      emit(const OnboardingSuccess('document'));
    } catch (e) {
      String message = 'Document upload failed';
      if (e is DioException) {
        final detail = e.response?.data['detail'];
        if (detail is List) {
          message = detail.map((e) => e['msg'] ?? e.toString()).join('\n');
        } else if (detail is String) {
          message = detail;
        } else {
          message = e.message ?? 'An error occurred';
        }
      }
      emit(OnboardingError(message));
    }
  }
}
