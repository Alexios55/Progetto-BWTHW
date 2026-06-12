import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/weight_entry.dart';
import 'package:bwthw_project/models.2/user.dart';
import 'package:bwthw_project/widgets/date_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Patient patient;

  const EditProfileScreen({super.key, required this.patient});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late Gender selectedGender;
  late TextEditingController birthDateController;
  late DateTime birthDate;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.patient.name);
    surnameController = TextEditingController(text: widget.patient.surname);
    selectedGender = widget.patient.gender;
    birthDate = widget.patient.birthDate;
    birthDateController = TextEditingController(
      text: widget.patient.birthDate.toIso8601String().split('T').first,
    );
  }

  void _saveChanges() async {

    final updatedPatient = widget.patient.copyWith(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      gender: selectedGender,
      birthDate: birthDate,
    );

    await PreferenceService.savePatient(updatedPatient);
    await PreferenceService.saveUser(User(
      name: updatedPatient.name,
      surname: updatedPatient.surname,
      birthDate: updatedPatient.birthDate,
    ));

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
            DateInputField(
              controller: birthDateController,
              label: 'Date of Birth',
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateParsed: (date) {
                if (date != null) birthDateController = birthDateController;
              },
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