import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/services/impact.dart';
import 'package:bwthw_project/utils/impact.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bwthw_project/models.2/patient.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Impact impact = Impact();

  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter your username and password.'),
          ),
        );
      return;
    }

    setState(() => _isLoading = true);

    print('LOGIN APP username inserito: $username');
    print('USERNAME IMPACT corretto: ${ImpactConfig.username}');
    print('PATIENT USERNAME per dati: ${ImpactConfig.patientUsername}');

    final result = await impact.getAndStoreTokens(username, password);

    if (!mounted) return;

    if (result == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user', username);
      await prefs.setString('password', password);
      await prefs.setBool('isLoggedIn', true);

      print('LOGIN OK - ora provo a prendere i dati IMPACT');

      try {
        final steps = await impact.getStepsData(DateTime.now());
        final calories = await impact.getCaloriesData(DateTime.now());
        final distance = await impact.getDistanceData(DateTime.now());

        print('STEPS trovati: ${steps.length}');
        print('CALORIES trovate: ${calories.length}');
        print('DISTANCE trovata: ${distance.length}');
      } catch (e) {
        print('ERRORE durante il test dati IMPACT: $e');
      }

      final patientJson = prefs.getString('patient');

      if (patientJson != null) {
        try {
          final patient = Patient.fromMap(jsonDecode(patientJson));
          context.read<PatientState>().setPatient(patient);
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            content: Text(
              result == 401
                  ? 'Incorrect username or password'
                  : 'Connection error (code $result). Please try again.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Please enter your user and password to sign in',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sign in to continue your journey with smartDIET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 28),

                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'User',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registration');
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}