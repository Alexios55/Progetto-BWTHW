import 'package:bwthw_project/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  static const routeName = '/personal-info';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please, enter your personal information to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                const CustomTextField(hintText: 'Sex'),
                const SizedBox(height: 20),
                const CustomTextField(hintText: 'Date of birth'),
                const SizedBox(height: 20),
                const CustomTextField(hintText: 'Age'),
                const SizedBox(height: 20),
                const CustomTextField(hintText: 'Weight (kg)'),
                const SizedBox(height: 20),
                const CustomTextField(hintText: 'Height (cm)'),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Collegheremo dopo la schermata successiva
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}