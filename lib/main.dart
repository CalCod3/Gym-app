// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fit_nivel/providers/activity_provider.dart';
import 'package:fit_nivel/providers/communications_provider.dart';
import 'package:fit_nivel/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'const.dart';
import 'providers/payment_plan_provider.dart';
import 'providers/performance_provider.dart';
import 'providers/post_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/user_provider.dart';
import 'providers/box_provider.dart'; // Import the BoxProvider
import 'splash_screen.dart'; // Import the splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");  // Ensures .env file is loaded before runApp
  } catch (e) {
    print("Error loading .env file: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(context.read<AuthProvider>()),
          update: (context, authProvider, previousUserProvider) {
            if (previousUserProvider != null) {
              previousUserProvider.updateAuthProvider(authProvider);
              return previousUserProvider;
            } else {
              return UserProvider(authProvider);
            }
          },
        ),
        
        ChangeNotifierProxyProvider<UserProvider, PostProvider>(
          create: (_) => PostProvider(ApiService('')),  // Initially empty token
          update: (context, userProvider, previousPostProvider) {
            final token = userProvider.authProvider?.token ?? '';
            if (previousPostProvider == null) {
              return PostProvider(ApiService(token));
            } else {
              previousPostProvider.updateToken(token);  // Ensure token gets updated
              return previousPostProvider;
            }
          },
        ),

        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => CommunicationsProvider()),
        ChangeNotifierProvider(create: (_) => GroupWorkoutProvider()),
        ChangeNotifierProvider(create: (_) => PaymentPlanProvider()),
        ChangeNotifierProvider(create: (_) => BoxProvider()),  // BoxProvider added
      ],
      child: MaterialApp(
        title: 'FitNivel',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          primaryColor: MaterialColor(
            primaryColorCode,
            <int, Color>{
              50: const Color(primaryColorCode).withOpacity(0.1),
              100: const Color(primaryColorCode).withOpacity(0.2),
              200: const Color(primaryColorCode).withOpacity(0.3),
              300: const Color(primaryColorCode).withOpacity(0.4),
              400: const Color(primaryColorCode).withOpacity(0.5),
              500: const Color(primaryColorCode).withOpacity(0.6),
              600: const Color(primaryColorCode).withOpacity(0.7),
              700: const Color(primaryColorCode).withOpacity(0.8),
              800: const Color(primaryColorCode).withOpacity(0.9),
              900: const Color(primaryColorCode).withOpacity(1.0),
            },
          ),
          scaffoldBackgroundColor: const Color(0xFF171821),
          fontFamily: 'IBMPlexSans',
          brightness: Brightness.dark,
        ),
        home: const SplashScreen(),  // Set the splash screen as the home
      ),
    );
  }
}
