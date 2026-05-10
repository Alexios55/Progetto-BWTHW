import 'package:flutter/material.dart';
import 'package:bwthw_project/models.2/body_measurement_entry.dart';

class AddBodyMeasurementScreen extends StatefulWidget {
  const AddBodyMeasurementScreen({super.key});

  @override
  State<AddBodyMeasurementScreen> createState() =>
      _AddBodyMeasurementScreenState();
}

class _AddBodyMeasurementScreenState extends State<AddBodyMeasurementScreen> {
  final chestController = TextEditingController();
  final armController = TextEditingController();
  final waistController = TextEditingController();
  final hipsController = TextEditingController();
  final thighController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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

  double? _parseValue(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void _save() {
    final chest = _parseValue(chestController.text);
    final arm = _parseValue(armController.text);
    final waist = _parseValue(waistController.text);
    final hips = _parseValue(hipsController.text);
    final thigh = _parseValue(thighController.text);

    if (chest == null ||
        arm == null ||
        waist == null ||
        hips == null ||
        thigh == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter valid numbers in all fields'),
          ),
        );
      return;
    }

    final entry = BodyMeasurementEntry(
      date: selectedDate,
      chest: chest,
      arm: arm,
      waist: waist,
      hips: hips,
      thigh: thigh,
    );

    Navigator.pop(context, entry);
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: '$label (cm)',
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    chestController.dispose();
    armController.dispose();
    waistController.dispose();
    hipsController.dispose();
    thighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Measurements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
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
                      ),
                    ),
                    const Icon(Icons.edit_calendar_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _field(context, 'Chest', chestController),
            _field(context, 'Arm', armController),
            _field(context, 'Waist', waistController),
            _field(context, 'Hips', hipsController),
            _field(context, 'Thigh', thighController),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}