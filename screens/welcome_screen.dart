import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String currentTheme;
  final String currentColor;
  final OnThemeColorChanged onThemeChanged;

  const WelcomeScreen({
    super.key,
    required this.currentTheme,
    required this.currentColor,
    required this.onThemeChanged,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            currentTheme: widget.currentTheme,
            currentColor: widget.currentColor,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/welcome/welcome_gdg_probation.gif'),
      ),
    );
  }
}
