import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/utils/input_validators.dart';
import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  static const routeName = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  Gender? selectedSex;
  ActivityLevel selectedActivityLevel = ActivityLevel.moderatelyActive;
  Goal selectedGoal = Goal.loseWeight;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  DateTime _parseDateOfBirth(String value) {
    final parts = value.split('/');

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  double _calculateIdealWeight(double heightCm) {
    final heightM = heightCm / 100.0;
    return 22 * heightM * heightM;
  }

  Future<void> _savePersonalInfoAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double weight =
        double.parse(weightController.text.replaceAll(',', '.'));
    final double height =
        double.parse(heightController.text.replaceAll(',', '.'));
    final int age = int.parse(ageController.text);
    final DateTime birthDate = _parseDateOfBirth(dateOfBirthController.text);
    final double idealWeight = _calculateIdealWeight(height);

    final prefs = await SharedPreferences.getInstance();

    final savedUser = prefs.getString('user') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    final patient = Patient(
      id: 'patient_1',
      name: 'Patient',
      user: savedUser,
      password: savedPassword,
      age: age,
      weightKg: weight,
      heightCm: height,
      gender: selectedSex ?? Gender.male,
      goal: selectedGoal,
      activityLevel: selectedActivityLevel,
    );

    await prefs.setString('patient', jsonEncode(patient.toMap()));

    await prefs.setString('name', patient.name);
    await prefs.setString('surname', '');
    await prefs.setString('birthDate', birthDate.toIso8601String());
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setDouble('idealWeight', idealWeight);
    await prefs.setBool('onboardingDone', true);

    if (!mounted) return;

    context.read<PatientState>().setPatient(patient);

    print('PATIENT salvato nelle SharedPreferences');
    print('User: $savedUser');
    print('Weight: $weight');
    print('Height: $height');
    print('Birth date: $birthDate');
    print('Ideal weight: $idealWeight');

    Navigator.pushNamed(context, '/bmi-status');
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

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

                const SizedBox(height: 12),

                Text(
                  'Your information helps us personalize your journey.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          DropdownButtonFormField<Gender>(
                            initialValue: selectedSex,
                            decoration: InputDecoration(
                              hintText: 'Sex',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: Gender.values
                                .map(
                                  (gender) => DropdownMenuItem<Gender>(
                                    value: gender,
                                    child: Text(gender.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSex = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select your sex' : null,
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: dateOfBirthController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              hintText: 'Date of birth',
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) =>
                                InputValidators.validateRequired(
                              value,
                              fieldName: 'Date of birth',
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Age',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              suffixText: 'years',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator: InputValidators.validateAge,
                          ),

                          const SizedBox(height: 20),

                          DropdownButtonFormField<ActivityLevel>(
                            initialValue: selectedActivityLevel,
                            decoration: InputDecoration(
                              hintText: 'Activity level',
                              prefixIcon:
                                  const Icon(Icons.directions_walk_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: ActivityLevel.values
                                .map(
                                  (level) => DropdownMenuItem<ActivityLevel>(
                                    value: level,
                                    child: Text(level.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                selectedActivityLevel = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          DropdownButtonFormField<Goal>(
                            initialValue: selectedGoal,
                            decoration: InputDecoration(
                              hintText: 'Goal',
                              prefixIcon: const Icon(Icons.flag_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: Goal.values
                                .map(
                                  (goal) => DropdownMenuItem<Goal>(
                                    value: goal,
                                    child: Text(goal.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                selectedGoal = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: weightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Weight',
                                    prefixIcon: const Icon(
                                      Icons.monitor_weight_outlined,
                                    ),
                                    suffixText: 'kg',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  validator: InputValidators.validateWeight,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: TextFormField(
                                  controller: heightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Height',
                                    prefixIcon: const Icon(Icons.height),
                                    suffixText: 'cm',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  validator: InputValidators.validateHeight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _savePersonalInfoAndContinue,
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