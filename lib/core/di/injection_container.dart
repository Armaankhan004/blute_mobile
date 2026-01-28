import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blute_mobile/features/subscription/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:blute_mobile/features/profile/presentation/bloc/upload/upload_bloc.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(() => SubscriptionBloc());
  sl.registerFactory(() => UploadBloc());
  sl.registerFactory(() => OnboardingBloc());

  // Use cases

  // Repository

  // Data sources

  // Core
  sl.registerLazySingleton(() => GlobalKey<NavigatorState>());

  // External
}
