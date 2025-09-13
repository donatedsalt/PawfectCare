import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pawfect_care/main.dart';
import 'package:pawfect_care/pages/store/home_page.dart';
import 'package:pawfect_care/utils/theme.dart'; // For BrandColors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start fade-in after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to AuthGate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [BrandColors.primaryBlue, BrandColors.cardBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1), // fade-in duration
                curve: Curves.easeIn,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                child: const Text(
                  'Pawfect Care',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
