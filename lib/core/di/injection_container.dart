import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blute_mobile/features/subscription/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:blute_mobile/features/profile/presentation/bloc/upload/upload_bloc.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:blute_mobile/core/network/dio_client.dart';
import 'package:blute_mobile/features/profile/data/upload_remote_datasource.dart';
import 'package:blute_mobile/features/subscription/data/subscription_remote_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(() => SubscriptionBloc(remoteDataSource: sl()));
  sl.registerFactory(() => UploadBloc(dataSource: sl()));
  sl.registerFactory(() => OnboardingBloc());

  // Use cases

  // Repository

  // Data sources
  sl.registerLazySingleton(() => UploadRemoteDataSource(dioClient: sl()));
  sl.registerLazySingleton(() => SubscriptionRemoteDataSource());

  // Core
  sl.registerLazySingleton(() => GlobalKey<NavigatorState>());
  sl.registerLazySingleton(() => DioClient());

  // External
}
