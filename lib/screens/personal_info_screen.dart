import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/services/user_service.dart';
import 'package:bwthw_project/utils/input_validators.dart';
import 'package:flutter/material.dart';

// This screen collects the user's personal information,
// such as sex, date of birth, age, weight, and height,
// before moving to the next onboarding step.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  static const routeName = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers used to manage the text shown inside the fields.
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Variable used to store the selected sex.
  Gender? selectedSex;
  ActivityLevel selectedActivityLevel = ActivityLevel.moderatelyActive;
  Goal selectedGoal = Goal.loseWeight;

  // Opens the date picker and writes the selected date into the text field.
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2000);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free memory when the screen is removed.
    dateOfBirthController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Main title of the screen.
                const Text(
                  'Personal Informaition',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle that explains what the user has to do.
                Text(
                  'Please, enter your personal information to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                // Small helper text to make the screen feel more personalized.
                Text(
                  'Your information helps us personalize your journey.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Main card that contains all personal information fields.
                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Dropdown field for sex selection.
                          DropdownButtonFormField<Gender>(
                            value: selectedSex,
                            decoration: InputDecoration(
                              hintText: 'Sex',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: Gender.values
                                .map(
                                  (gender) => DropdownMenuItem<Gender>(
                                    value: gender,
                                    child: Text(gender.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSex = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select your sex' : null,
                          ),

                          const SizedBox(height: 20),

                          // Read-only field for date of birth.
                          // When tapped, it opens the calendar picker.
                          TextFormField(
                            controller: dateOfBirthController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: InputDecoration(
                              hintText: 'Date of birth',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator:
                                (value) => InputValidators.validateRequired(
                                  value,
                                  fieldName: 'Date of birth',
                                ),
                          ),

                          const SizedBox(height: 20),

                          // Age field.
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Age',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              suffixText: 'years',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            validator: InputValidators.validateAge,
                          ),

                          const SizedBox(height: 20),

                          DropdownButtonFormField<ActivityLevel>(
                            value: selectedActivityLevel,
                            decoration: InputDecoration(
                              hintText: 'Activity level',
                              prefixIcon:
                                  const Icon(Icons.directions_walk_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: ActivityLevel.values
                                .map(
                                  (level) => DropdownMenuItem<ActivityLevel>(
                                    value: level,
                                    child: Text(level.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                selectedActivityLevel = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          DropdownButtonFormField<Goal>(
                            value: selectedGoal,
                            decoration: InputDecoration(
                              hintText: 'Goal',
                              prefixIcon: const Icon(Icons.flag_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            items: Goal.values
                                .map(
                                  (goal) => DropdownMenuItem<Goal>(
                                    value: goal,
                                    child: Text(goal.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                selectedGoal = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Weight and height are displayed side by side
                          // to make the layout more compact and modern.
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Weight',
                                    prefixIcon: const Icon(
                                      Icons.monitor_weight_outlined,
                                    ),
                                    suffixText: 'kg',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  validator: InputValidators.validateWeight,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Height',
                                    prefixIcon: const Icon(Icons.height),
                                    suffixText: 'cm',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                  validator: InputValidators.validateHeight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Main button used to continue to the next step.
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final double weight =
                          double.parse(weightController.text.replaceAll(',', '.'));
                      final double height =
                          double.parse(heightController.text.replaceAll(',', '.'));
                      final int age = int.parse(ageController.text);

                      UserService().setUserData(
                        weight: weight,
                        height: height,
                        age: age,
                        gender: selectedSex ?? Gender.male,
                        activityLevel: selectedActivityLevel,
                        goal: selectedGoal,
                      );

                      Patient patient = Patient(
                        id: 'patient_1',
                        name: 'Patient',
                        email: '',
                        age: age,
                        weightKg: weight,
                        heightCm: height,
                        gender: selectedSex ?? Gender.male,
                        goal: selectedGoal,
                        activityLevel: selectedActivityLevel,
                      );

                      Provider.of<PatientState>(context, listen: false).setPatient(patient);


                      Navigator.pushNamed(context, '/bmi-status');
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


