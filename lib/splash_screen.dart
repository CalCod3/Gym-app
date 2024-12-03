// ignore_for_file: unused_field, unused_import, use_build_context_synchronously, avoid_print

import 'package:WOD_Book/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'auth/login_page.dart';
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
    Future.delayed(const Duration(seconds: 2), () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Load the token from storage (if any)
      await authProvider.loadToken();

      // Ensure we're still in the correct context
      if (!mounted) return;

      // Navigate based on token validity
      if (authProvider.token == null) {
        // Navigate to the login page if no valid token
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        try {
          // Fetch user data after token authentication
          await userProvider.fetchUserData();

          // Ensure we're still in the correct context
          if (!mounted) return;

          // Navigate to the dashboard if successful
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashBoard()),
          );
        } catch (e) {
          print('Error fetching user data: $e'); // Debug print
          // Navigate to login if fetching user data fails
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
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
    // Animated splash screen UI
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 192, 252),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated image with popping effect
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: 1.2),
            duration: const Duration(milliseconds: 700),
            curve: Curves.fastOutSlowIn,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Image.asset(
                  'assets/images/wodbook.png', // Replace with your actual image path
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
