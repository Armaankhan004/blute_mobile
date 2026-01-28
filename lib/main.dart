import 'package:blute_mobile/features/gigs/presentation/screens/booking_confirmation_screen.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/booking_success_screen.dart';
import 'package:blute_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:blute_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/slot_details_screen.dart';
import 'package:blute_mobile/features/gigs/presentation/screens/slot_selection_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/screens/bank_details_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/screens/document_upload_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:blute_mobile/features/profile/presentation/screens/upload_screenshots_screen.dart';
import 'package:blute_mobile/features/subscription/presentation/screens/subscription_selection_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/screens/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blute_mobile/core/di/injection_container.dart' as di;
import 'package:blute_mobile/core/theme/app_theme.dart';
import 'package:blute_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blute_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:blute_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:blute_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';

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
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<OnboardingBloc>()),
      ],
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
          '/bank-details': (context) => const BankDetailsScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),

          '/success': (context) => const SuccessScreen(),
          '/slot-details': (context) => const SlotDetailsScreen(),
          '/slot-selection': (context) => const SlotSelectionScreen(),
          '/booking-confirmation': (context) =>
              const BookingConfirmationScreen(),
          '/booking-success': (context) => const BookingSuccessScreen(),
          '/upload_screenshot': (context) => const UploadScreenshotsScreen(),
          '/subscription_selection': (context) =>
              const SubscriptionSelectionScreen(),
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
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
