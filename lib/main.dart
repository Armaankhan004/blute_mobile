import 'package:blute_mobile/features/onboarding/presentation/screens/document_upload_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/di/injection_container.dart' as di;
import 'package:blute_mobile/core/theme/app_theme.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blute_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:blute_mobile/features/auth/presentation/screens/otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => di.sl<AuthBloc>())],
      child: MaterialApp(
        navigatorKey: di.sl<GlobalKey<NavigatorState>>(),
        title: 'Blute.AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/otp': (context) => const OtpScreen(),
          '/profile-setup': (context) => ProfileSetupScreen(),
          '/document-upload': (context) => DocumentUploadScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
