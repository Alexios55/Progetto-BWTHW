import 'package:flutter/material.dart';
import 'package:bwthw_project/models/user.dart';
import 'package:bwthw_project/services/preference_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    surnameController = TextEditingController(text: widget.user.surname);
    weightController =
        TextEditingController(text: widget.user.weight.toString());
    heightController =
        TextEditingController(text: widget.user.height.toString());
  }

  void _saveChanges() async {
    final updatedUser = User(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      birthDate: widget.user.birthDate,
      weight: double.tryParse(weightController.text) ?? widget.user.weight,
      height: double.tryParse(heightController.text) ?? widget.user.height,
      idealWeight: widget.user.idealWeight,
    );

    await PreferenceService.saveUser(updatedUser);

    Navigator.pop(context, true); // 👈 ritorna "true"
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