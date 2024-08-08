import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khata_app/views/screens/users_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  void navToNext() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if the widget is still mounted before navigating
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UsersScreen()),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    navToNext();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid potential memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 300,
                  width: 250,
                  child: Image.asset(
                    "assets/images/splash_logo.jpeg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}