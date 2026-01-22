import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc());

  // Use cases

  // Repository

  // Data sources

  // Core
  sl.registerLazySingleton(() => GlobalKey<NavigatorState>());

  // External
}
