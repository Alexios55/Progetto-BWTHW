import 'package:flutter/material.dart';
import 'package:bwthw_project/models/blood_test.dart';

class AddBloodTestScreen extends StatefulWidget {
  const AddBloodTestScreen({super.key});

  @override
  State<AddBloodTestScreen> createState() => _AddBloodTestScreenState();
}

class _AddBloodTestScreenState extends State<AddBloodTestScreen> {
  final iron = TextEditingController();
  final calcium = TextEditingController();
  final glucose = TextEditingController();
  final cholesterol = TextEditingController();
  final vitaminD = TextEditingController();

  void save() {
    final test = BloodTest(
      date: DateTime.now(),
      iron: double.parse(iron.text),
      calcium: double.parse(calcium.text),
      glucose: double.parse(glucose.text),
      cholesterol: double.parse(cholesterol.text),
      vitaminD: double.parse(vitaminD.text),
    );

    Navigator.pop(context, test);
  }

  Widget field(
    BuildContext context,
    String label,
    String unit,
    TextEditingController c,
    String desc,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$label ($unit)',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Blood Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            field(context, 'Iron', 'µg/dL', iron,
                'Transports oxygen in blood'),
            field(context, 'Calcium', 'mg/dL', calcium,
                'Important for bones and muscles'),
            field(context, 'Glucose', 'mg/dL', glucose,
                'Main energy source'),
            field(context, 'Cholesterol', 'mg/dL', cholesterol,
                'Linked to heart health'),
            field(context, 'Vitamin D', 'ng/mL', vitaminD,
                'Helps calcium absorption'),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}