import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/weight_entry.dart';
import 'package:bwthw_project/models.2/user.dart';

class EditProfileScreen extends StatefulWidget {
  final Patient patient;

  const EditProfileScreen({super.key, required this.patient});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late Gender selectedGender;
  late ActivityLevel selectedActivity;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.patient.name);
    surnameController = TextEditingController(text: widget.patient.surname);
    weightController =
        TextEditingController(text: widget.patient.weight.toString());
    heightController =
        TextEditingController(text: widget.patient.height.toString());
    selectedGender = widget.patient.gender;
    selectedActivity = widget.patient.activityLevel;
  }

  void _saveChanges() async {
    final newWeight = double.tryParse(weightController.text) ?? widget.patient.weightKg;
    final newHeight = double.tryParse(heightController.text) ?? widget.patient.heightCm;

    final updatedPatient = widget.patient.copyWith(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      weightKg: newWeight,
      heightCm: newHeight,
      gender: selectedGender,
      activityLevel: selectedActivity,
    );

    await PreferenceService.savePatient(updatedPatient);
    await PreferenceService.saveUser(User(
      name: updatedPatient.name,
      surname: updatedPatient.surname,
      birthDate: updatedPatient.birthDate,
      weight: updatedPatient.weightKg,
      height: updatedPatient.heightCm,
      idealWeight: updatedPatient.targetWeightKg ?? 0,
    ));

    if (newWeight != widget.patient.weightKg) {
      await PreferenceService.addWeightEntry(
        WeightEntry(
          date: DateTime.now(),
          weight: newWeight,
        ),
      );
    }

    if (mounted) {
      context.read<PatientState>().setPatient(updatedPatient);
      Navigator.pop(context, true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: surnameController, decoration: const InputDecoration(labelText: 'Surname')),
            TextField(controller: weightController, decoration: const InputDecoration(labelText: 'Weight')),
            TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height')),

            const SizedBox(height: 16),
            DropdownButtonFormField<Gender>(
              value: selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: Gender.values.map((g) => DropdownMenuItem(
                value: g,
                child: Text(g.name),
              )).toList(),
              onChanged: (v) => setState(() => selectedGender = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityLevel>(
              value: selectedActivity,
              decoration: const InputDecoration(labelText: 'Activity Level'),
              items: ActivityLevel.values.map((a) => DropdownMenuItem(
                value: a,
                child: Text(a.name),
              )).toList(),
              onChanged: (v) => setState(() => selectedActivity = v!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}