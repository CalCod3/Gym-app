// ignore_for_file: avoid_print, unused_element

import 'dart:async';
import 'package:WOD_Book/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:WOD_Book/providers/activity_provider.dart';
import 'package:WOD_Book/providers/communications_provider.dart';
import 'package:WOD_Book/services/api_service.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  // Ensure Flutter bindings are initialized in the correct zone
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app within a guarded zone
  runZonedGuarded(() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      print("Firebase initialized successfully.");

      // Load .env variables BEFORE initializing NotificationService
      await dotenv.load(fileName: ".env");
      print(".env file loaded successfully.");

      // Initialize NotificationService
      NotificationService.create();

      // Start the app
      runApp(const MyApp());
    } 
    catch (error, stackTrace) {
      print("Caught error in runZonedGuarded: $error");
      print(stackTrace);
    }
  }, 
  (error, stackTrace) {
    print("Caught error in runZonedGuarded: $error\n$stackTrace");
  });

  // Flutter framework error handler
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print("Flutter framework error caught: ${details.exceptionAsString()}");
    print(details.stack.toString());
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building MyApp widget...");

    // Global error widget to handle build errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      print("ErrorWidget triggered: ${details.exceptionAsString()}");
      return Center(
        child: Text(
          "Something went wrong!",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadToken(),
        ),
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
          create: (_) => PostProvider(ApiService('')),
          update: (context, userProvider, previousPostProvider) {
            final token = userProvider.authProvider?.token ?? '';
            if (previousPostProvider == null) {
              return PostProvider(ApiService(token));
            } else {
              previousPostProvider.updateToken(token);
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
        ChangeNotifierProvider(create: (_) => BoxProvider()),
      ],
      child: MaterialApp(
        title: 'WODBOOK',
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false, // Displays material grid for layout debugging
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
        home: const SplashScreen(),
      ),
    );
  }
}
