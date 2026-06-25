import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 20,
      ),
    ]).animate(_animationController);

    _animationController.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = false;

    try {
      isLoggedIn = await PreferenceService.getLogin().timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      isLoggedIn = false;
    }

    if (isLoggedIn) {
      try {
        await context.read<PatientState>().loadFromPreferences().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {}
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/start');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF405F91),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SvgPicture.asset(
            'assets/images/SMARTDIET.svg',
            width: 280,
            height: 280,
          ),
        ),
      ),
    );
  }
}