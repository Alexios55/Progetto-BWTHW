
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/user_temp.dart';
import 'package:bwthw_project/screens/onboarding/bmi_status.dart';
import 'package:bwthw_project/services/user_service.dart';
import 'package:bwthw_project/utils/calculate_age.dart';
import 'package:bwthw_project/widgets/date_input_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  static const routeName = '/personal-info';

  final UserTemp user;

  const PersonalInfoScreen({super.key, required this.user});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  late int age;
  late DateTime birthDate;

  String? selectedSex;
  String? activityLevel;

  void _onDateParsed(DateTime? date) {
    if (date == null) {
      setState(() => ageController.clear());
      return;
    }
    if (date.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Please enter a date of birth that is not in the future'),
          duration: Duration(seconds: 2),
        ));
      return;
    }
    setState(() {
      age = AgeCalculator.calculateAge(date);
      birthDate = date;
      ageController.text = age.toString();
    });
  }

  void _goToNextStep() {
    if (selectedSex == null ||
        dateOfBirthController.text.isEmpty ||
        ageController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        activityLevel == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    if (age < 16) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('You must be at least 16 years old to use this app'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    } else {
      ageController.text = age.toString();
    }

    final double? weightValue =
        double.tryParse(weightController.text.replaceAll(',', '.'));
    if (weightValue == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Weight must be a valid number'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    final double? heightValue =
        double.tryParse(heightController.text.replaceAll(',', '.'));
    if (heightValue == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Height must be a valid number'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    final gender = _parseGender(selectedSex!);
    final parsedActivityLevel = _parseActivityLevel(activityLevel!);

    widget.user.weight = weightValue;
    widget.user.height = heightValue;
    widget.user.dateOfBirth = birthDate;

    UserService().setUserData(
      weight: weightValue,
      height: heightValue,
      age: age,
      gender: gender,
      activityLevel: parsedActivityLevel,
    );

    final patient = Patient(
      id: 'patient_1',
      name: widget.user.name ?? 'Patient',
      surname: widget.user.surname ?? '',
      email: '',
      age: age,
      weightKg: weightValue,
      heightCm: heightValue,
      gender: gender,
      activityLevel: parsedActivityLevel,
      birthDate: birthDate,
    );

    Provider.of<PatientState>(context, listen: false).setPatient(patient);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BmiStatusScreen(
          user: widget.user,
          patient: patient,
        ),
      ),
    );
  }

  ActivityLevel _parseActivityLevel(String value) {
    switch (value) {
      case 'Sedentary':
        return ActivityLevel.sedentary;
      case 'Lightly Active':
        return ActivityLevel.lightlyActive;
      case 'Moderately Active':
        return ActivityLevel.moderatelyActive;
      case 'Athlete':
        return ActivityLevel.athlete;
      default:
        return ActivityLevel.moderatelyActive;
    }
  }

  Gender _parseGender(String value) {
    switch (value) {
      case 'Male':
        return Gender.male;
      case 'Female':
        return Gender.female;
      default:
        return Gender.other;
    }
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
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
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
                            Icons.badge_outlined,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tell us about you',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter your personal information to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSex,
                          decoration: InputDecoration(
                            hintText: 'Sex',
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
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSex = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        DateInputField(
                          controller: dateOfBirthController,
                          label: 'Date of Birth',
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          onDateParsed: _onDateParsed,
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: ageController,
                          readOnly: true,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            hintText: 'Age',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            suffixText: 'years',
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
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
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
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: heightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Height',
                                  prefixIcon: const Icon(Icons.height),
                                  suffixText: 'cm',
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          initialValue: null,
                          decoration: InputDecoration(
                            hintText: 'Activity Level',
                            prefixIcon: const Icon(Icons.fitness_center),
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
                          items: const [
                            DropdownMenuItem(
                              value: 'Sedentary',
                              child: Text('Sedentary'),
                            ),
                            DropdownMenuItem(
                              value: 'Lightly Active',
                              child: Text('Lightly Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Moderately Active',
                              child: Text('Moderately Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Athlete',
                              child: Text('Athlete'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              activityLevel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _goToNextStep,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

