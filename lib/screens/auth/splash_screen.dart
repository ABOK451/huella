import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';


class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      // Aquí normalmente comprobarías si hay sesión activa
      // si es primera vez -> OnboardingScreen, si no -> LoginScreen o Home
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, size: 96, color: Colors.white),
            SizedBox(height: 20),
            Text('Huella+', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Suma acciones. Cambia el mundo.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
