import 'package:flutter/material.dart';
import 'package:bwthw_project/models/user_temp.dart';
import 'package:bwthw_project/widgets/bmi_bar.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models/user.dart';

/// This screen shows the user's BMI result, the current physical status,
/// a short explanation, and a field where the user can enter an ideal weight.
/// For now, the screen uses default placeholder values, but it is already
/// prepared to receive dynamic values later.
class BmiStatusScreen extends StatefulWidget {
  final UserTemp user;
  const BmiStatusScreen({
    super.key,
    required this.user,
  });

  static const routeName = '/bmi-status';

  @override
  State<BmiStatusScreen> createState() => _BmiStatusScreenState();
}

class _BmiStatusScreenState extends State<BmiStatusScreen> {
  final TextEditingController idealWeightController = TextEditingController();

  // Calculating BMI using the user's weight and height.
  double get bmi {
  double weight = widget.user.weight!;
  double height = widget.user.height! / 100;

  return weight / (height * height);
  }

  // Determining the physical status based on the BMI value.
  String get status {
    double bmiValue = bmi;

    if (bmiValue < 18.5) {
      return 'Underweight';
    } else if (bmiValue < 25) {
      return 'Normal';
    } else if (bmiValue < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Determinating the colur associated with the physical status.
  Color get statusColor {
    switch (status) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Providing a description for each physical status.
  String get description {
    switch (status) {
      case 'Underweight':
        return 'Your BMI indicates that you are underweight. It is important to ensure you are consuming enough nutrients to support your health. Consider improving your nutrition.';
      case 'Normal':
        return 'Your BMI is within the normal range. Keep up the good work maintaining a healthy lifestyle!';
      case 'Overweight':
        return 'Your BMI indicates that you are overweight. Consider adopting a balanced diet and regular physical activity to improve your health.';
      case 'Obese':
        return 'Your BMI indicates that you are obese. It is advisable to consult with a healthcare professional for personalized guidance on achieving a healthier weight.';
      default:
        return '';
    }
  }

  // Providing a recommended weight range based on the user's height.
  String get recommendedWeight {
    double height = widget.user.height! / 100;
    double minWeight = 18.5 * (height * height);
    double maxWeight = 24.9 * (height * height);

    return '${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} kg';
  }

  @override
  void dispose() {
    idealWeightController.dispose();
    super.dispose();
  }

void _goToHome() async {
  final String idealWeight = idealWeightController.text.trim();

  if (idealWeight.isEmpty) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Please enter your ideal weight'),
        ),
      );
    return;
  }

  final double? idealWeightValue =
      double.tryParse(idealWeight.replaceAll(',', '.'));

  if (idealWeightValue == null) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Ideal weight must be a valid number'),
        ),
      );
    return;
  }

  widget.user.idealWeight = idealWeightValue;

  await finishOnboarding();
}

Future<void> finishOnboarding() async {
  User user = User(
    name: widget.user.name!,
    surname: widget.user.surname!,
    birthDate: widget.user.dateOfBirth!, 
    weight: widget.user.weight!,
    height: widget.user.height!,
    idealWeight: widget.user.idealWeight ?? 0,
  );

  await PreferenceService.saveUser(user);
  await PreferenceService.saveOnboardingCompleted(true);

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/home',
    (route) => false,
    arguments: user,
  );
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
                  'Your current physical status is:',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your BMI is',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bmi.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.accessibility_new,
                                  size: 40,
                                  color: statusColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        BmiBar(
                          bmi: bmi,
                          statusColor: statusColor,
                        ),
                        const SizedBox(height: 20),
                        Divider(color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'What is your ideal weight?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: idealWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    filled: true,
                    fillColor:
                        colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended weight $recommendedWeight.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'The Body Mass Index (BMI) is a simple way to check if your weight is healthy for your height, categorizing it as underweight, normal, overweight, or obese.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _goToHome,
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
      ),
    );
  }
}