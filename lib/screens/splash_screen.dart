import 'package:flutter/material.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
    _checkLoginStatus();
  });
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await PreferenceService.getLogin();

    if (isLoggedIn) {
    await context.read<PatientState>().loadFromPreferences();
    }

    await Future.delayed(const Duration(seconds: 2));

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

