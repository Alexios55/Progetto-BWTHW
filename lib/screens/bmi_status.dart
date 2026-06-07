import 'package:flutter/material.dart';
import 'package:bwthw_project/logic/health_calculator.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/user_service.dart';

// This screen shows the user's current BMI status,
// an explanation of the result, and a field to enter the ideal weight.
class BmiStatusScreen extends StatelessWidget {
  const BmiStatusScreen({super.key});

  static const routeName = '/bmi-status';

  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal weight':
        return Colors.green;
      case 'Overweight':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final user = UserService();

    final double bmi = user.calculateBMI();
    final String status = _getBmiStatus(bmi);
    final Color statusColor = _getStatusColor(status);
    final patient = user.currentPatient;
    final healthyRange = HealthCalculator.calculateHealthyWeightRange(user.height);

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
                  'Your current physical status is:',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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

                        const SizedBox(height: 20),

                        Divider(color: colorScheme.outlineVariant),

                        const SizedBox(height: 16),

                        Text(
                          'Your BMI is categorized as "$status". '
                          'Maintain a balanced lifestyle for optimal health.',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Divider(color: colorScheme.outlineVariant),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _MetricTile(
                                label: 'BMR',
                                value: '${user.calculateBmr().toStringAsFixed(0)} kcal',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricTile(
                                label: 'TDEE',
                                value: '${user.calculateTdee().toStringAsFixed(0)} kcal',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _MetricTile(
                          label: 'Daily target',
                          value:
                              '${user.dailyCaloriesTarget.toStringAsFixed(0)} kcal (${patient != null ? patient.goal?.label : 'Goal not set'})',
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      'Recommended weight ${healthyRange.minKg.toStringAsFixed(0)} - ${healthyRange.maxKg.toStringAsFixed(0)} kg.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'The Body Mass Index (BMI) is a simple way to check if your '
                  'weight is healthy for your height, categorizing it as underweight, '
                  'normal, overweight, or obese.',
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
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

