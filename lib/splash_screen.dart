// ignore_for_file: unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_dashboard/auth/login_page.dart';
import 'package:flutter_dashboard/main.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();

    // Animation controller for the popping effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Simulate loading by completing the future after a delay
    Future.delayed(const Duration(seconds: 7), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DashBoard()));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 192, 252),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated image with popping effect
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.2),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Image.asset(
                  'assets/images/splash.png', // Replace with your actual image path
                  fit: BoxFit.contain,
                ),
              );
            },
            onEnd: () {
              _animationController.reverse();
            },
          ),
          const SizedBox(height: 20),
          // Linear progress indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
