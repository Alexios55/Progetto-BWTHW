import 'package:flutter/material.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = false;

    try {
      isLoggedIn =
          await PreferenceService.getLogin().timeout(const Duration(seconds: 3));
    } catch (_) {
      isLoggedIn = false;
    }

    if (isLoggedIn) {
      try {
        await context
            .read<PatientState>()
            .loadFromPreferences()
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 90,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text(
              'smartDIET',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

