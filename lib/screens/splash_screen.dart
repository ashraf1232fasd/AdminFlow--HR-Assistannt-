import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import '../core/neumorphic_style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: softShadow(),
          padding: const EdgeInsets.all(40),
          child: const Icon(Icons.account_balance_wallet,
              size: 80, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
