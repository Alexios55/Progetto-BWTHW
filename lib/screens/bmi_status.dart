import 'package:flutter/material.dart';

/// This screen shows the user's BMI result, the current physical status,
/// a short explanation, and a field where the user can enter an ideal weight.
/// For now, the screen uses default placeholder values, but it is already
/// prepared to receive dynamic values later.
class BmiStatusScreen extends StatefulWidget {
  const BmiStatusScreen({
    super.key,
    this.bmi = 23.0,
    this.status = 'Normal weight',
    this.statusColor = Colors.green,
    this.description =
        'Your BMI is within the normal weight range. Keep up with your current lifestyle to maintain a healthy weight.',
    this.recommendedWeight = '55 - 74 kg',
  });

  static const routeName = '/bmi-status';

  final double bmi;
  final String status;
  final Color statusColor;
  final String description;
  final String recommendedWeight;

  @override
  State<BmiStatusScreen> createState() => _BmiStatusScreenState();
}

class _BmiStatusScreenState extends State<BmiStatusScreen> {
  final TextEditingController idealWeightController = TextEditingController();

  @override
  void dispose() {
    idealWeightController.dispose();
    super.dispose();
  }

  void _goToHome() {
    final String idealWeight = idealWeightController.text.trim();

    if (idealWeight.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter your ideal weight'),
            duration: Duration(seconds: 2),
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
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    Navigator.pushNamed(context, '/home');
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
                                    widget.bmi.toStringAsFixed(1),
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
                                  color: widget.statusColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.status,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: widget.statusColor,
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
                          widget.description,
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
                      'Recommended weight ${widget.recommendedWeight}.',
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