import 'package:flutter/material.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/body_measurement_entry.dart';
import 'package:bwthw_project/widgets/date_input_field.dart';

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
  late final TextEditingController _dateController;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text:
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}',
    );
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

  void _onDateParsed(DateTime? date) {
    if (date == null) return;

    setState(() {
      selectedDate = date;
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    });
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
    _dateController.dispose();
    chestController.dispose();
    armController.dispose();
    waistController.dispose();
    hipsController.dispose();
    thighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Measurements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DateInputField(
              controller: _dateController,
              label: 'Date',
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              onDateParsed: _onDateParsed,
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