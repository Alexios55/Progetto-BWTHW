import 'package:flutter/material.dart';

/// This screen collects the user's personal information before
/// continuing to the next step of the onboarding flow.
/// The user must select sex, date of birth, age, weight, and height.
/// The screen also checks that:
/// - date of birth is 2010 or earlier
/// - age is numeric and has at least 2 digits
/// - weight is a valid number
/// - height is a valid number
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  static const routeName = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Controllers used to manage the text shown inside the fields.
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Variable used to store the selected sex.
  String? selectedSex;

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

  void _goToNextStep() {
    final String dateOfBirth = dateOfBirthController.text.trim();
    final String age = ageController.text.trim();
    final String weight = weightController.text.trim();
    final String height = heightController.text.trim();

    if (selectedSex == null ||
        dateOfBirth.isEmpty ||
        age.isEmpty ||
        weight.isEmpty ||
        height.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    // Check that the selected year is not later than 2010.
    final List<String> parts = dateOfBirth.split('/');
    if (parts.length != 3) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid date of birth'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    final int? year = int.tryParse(parts[2]);
    if (year == null || year > 2010) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Date of birth must be 2010 or earlier'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    // Check that age is numeric and has at least 2 digits.
    final RegExp ageRegExp = RegExp(r'^\d{2,}$');
    if (!ageRegExp.hasMatch(age)) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Age must be a number with at least 2 digits'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    // Check that weight is a valid number.
    final double? weightValue = double.tryParse(weight.replaceAll(',', '.'));
    if (weightValue == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Weight must be a valid number'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    // Check that height is a valid number.
    final double? heightValue = double.tryParse(height.replaceAll(',', '.'));
    if (heightValue == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Height must be a valid number'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    Navigator.pushNamed(context, '/bmi-status');
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
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enter your personal information to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Main box that contains the personal information form.
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedSex,
                          decoration: InputDecoration(
                            hintText: 'Sex',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSex = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: dateOfBirthController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            hintText: 'Date of birth',
                            prefixIcon:
                                const Icon(Icons.calendar_today_outlined),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
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
                        const SizedBox(height: 18),

                        TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Age',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            suffixText: 'years',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
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
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Weight',
                                  prefixIcon: const Icon(
                                    Icons.monitor_weight_outlined,
                                  ),
                                  suffixText: 'kg',
                                  filled: true,
                                  fillColor: colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.4),
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
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: heightController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Height',
                                  prefixIcon: const Icon(Icons.height),
                                  suffixText: 'cm',
                                  filled: true,
                                  fillColor: colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.4),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _goToNextStep,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}