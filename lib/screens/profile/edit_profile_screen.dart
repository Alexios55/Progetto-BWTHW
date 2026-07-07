import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/preference_service.dart';
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
  late TextEditingController usernameController;
  late TextEditingController password;
  late TextEditingController new_password;
  late TextEditingController confirm_password;

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
    usernameController = TextEditingController(text: widget.patient.user);
    password = TextEditingController();
    new_password = TextEditingController();
    confirm_password = TextEditingController();
  }

  void _saveChanges() async {

    final isChangingPassword = new_password.text.isNotEmpty || confirm_password.text.isNotEmpty;
    if(isChangingPassword){
      if (new_password.text != confirm_password.text) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('New password and confirmation do not match.')),
          );
        return;
      }

      // Chechk old password equal to the current password
      if (password.text != widget.patient.password) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Current password is incorrect.')),
          );
        return;
      }
    }

    final updatedPatient = widget.patient.copyWith(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      gender: selectedGender,
      birthDate: birthDate,
      user: usernameController.text.trim(),
      password: new_password.text.isNotEmpty ? new_password.text : widget.patient.password,
    );

    await PreferenceService.savePatient(updatedPatient);
    await PreferenceService.saveUser(User(
      name: updatedPatient.name,
      surname: updatedPatient.surname,
      birthDate: updatedPatient.birthDate,
      user: updatedPatient.user,
      password: updatedPatient.password,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update your personal information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                      const SizedBox(height: 8),
                      TextField(controller: surnameController, decoration: const InputDecoration(labelText: 'Surname')),
                      const SizedBox(height: 8),
                      TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
                      const SizedBox(height: 8),
                      TextField(controller: password, decoration: const InputDecoration(labelText: 'Current password')),
                      const SizedBox(height: 8),
                      TextField(controller: new_password, decoration: const InputDecoration(labelText: 'New password')),
                      const SizedBox(height: 8),
                      TextField(controller: confirm_password, decoration: const InputDecoration(labelText: 'Confirm new password')),
                      const SizedBox(height: 16),
                      DateInputField(
                        controller: birthDateController,
                        label: 'Date of Birth',
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onDateParsed: (date) {
                          if (date != null) {
                            setState(() {
                              birthDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
        ),
      ),
    ),
    );
  }
}