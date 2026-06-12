import 'package:flutter/material.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';

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

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void save() {
    final double? ironValue = double.tryParse(iron.text.replaceAll(',', '.'));
    final double? calciumValue =
        double.tryParse(calcium.text.replaceAll(',', '.'));
    final double? glucoseValue =
        double.tryParse(glucose.text.replaceAll(',', '.'));
    final double? cholesterolValue =
        double.tryParse(cholesterol.text.replaceAll(',', '.'));
    final double? vitaminDValue =
        double.tryParse(vitaminD.text.replaceAll(',', '.'));

    if (ironValue == null ||
        calciumValue == null ||
        glucoseValue == null ||
        cholesterolValue == null ||
        vitaminDValue == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter valid numbers in all fields'),
          ),
        );
      return;
    }

    final test = BloodTest(
      date: selectedDate,
      iron: ironValue,
      calcium: calciumValue,
      glucose: glucoseValue,
      cholesterol: cholesterolValue,
      vitaminD: vitaminDValue,
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
  void dispose() {
    iron.dispose();
    calcium.dispose();
    glucose.dispose();
    cholesterol.dispose();
    vitaminD.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Blood Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Date: ${_formatDate(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.edit_calendar_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            field(context, 'Iron', 'µg/dL', iron, 'Transports oxygen in blood'),
            field(context, 'Calcium', 'mg/dL', calcium, 'Important for bones and muscles'),
            field(context, 'Glucose', 'mg/dL', glucose, 'Main energy source'),
            field(context, 'Cholesterol', 'mg/dL', cholesterol, 'Linked to heart health'),
            field(context, 'Vitamin D', 'ng/mL', vitaminD, 'Helps calcium absorption'),
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