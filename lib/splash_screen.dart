import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_dashboard/main.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'dashboard.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
        'assets/images/splash.png', // Replace with your actual image path
        fit: BoxFit.contain, // Adjust the fit as per your image dimensions
      ),
      nextScreen: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.token == null) {
            return const HomePage();
          } else {
            return DashBoard();
          }
        },
      ),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.blue,
      duration: 3000, // Duration of the splash screen in milliseconds
    );
  }
}
