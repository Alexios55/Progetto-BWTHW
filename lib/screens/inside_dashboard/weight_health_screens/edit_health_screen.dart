import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/weight_entry.dart';
import 'package:bwthw_project/models.2/user.dart';

class EditHealthScreen extends StatefulWidget {
  final Patient patient;

  const EditHealthScreen({super.key, required this.patient});

  @override
  State<EditHealthScreen> createState() => _EditHealthScreenState();
}

class _EditHealthScreenState extends State<EditHealthScreen> {
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController targetWeightController;
  late ActivityLevel selectedActivity;
  
  String recommendedWeightRange = '-- - -- kg';

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: widget.patient.weightKg.toString());
    heightController = TextEditingController(text: widget.patient.heightCm.toString());
    targetWeightController = TextEditingController(
      text: widget.patient.targetWeightKg != null ? widget.patient.targetWeightKg.toString() : '',
    );
    selectedActivity = widget.patient.activityLevel;

    // Calcoliamo subito il range iniziale
    _updateRecommendedWeight();

    // Listener per aggiornare i consigli sul peso ideale in tempo reale se l'altezza cambia
    heightController.addListener(_updateRecommendedWeight);
  }

  void _updateRecommendedWeight() {
    final double? heightValue = double.tryParse(heightController.text.replaceAll(',', '.'));
    if (heightValue != null && heightValue > 0) {
      double heightMeters = heightValue / 100;
      double minWeight = 18.5 * (heightMeters * heightMeters);
      double maxWeight = 24.9 * (heightMeters * heightMeters);
      setState(() {
        recommendedWeightRange = '${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} kg';
      });
    } else {
      setState(() {
        recommendedWeightRange = '-- - -- kg';
      });
    }
  }

  void _saveChanges() async {
    // Validazione input numerici coerente con l'onboarding
    final double? newWeight = double.tryParse(weightController.text.replaceAll(',', '.'));
    final double? newHeight = double.tryParse(heightController.text.replaceAll(',', '.'));
    final double? newTargetWeight = double.tryParse(targetWeightController.text.replaceAll(',', '.'));

    if (newWeight == null || newHeight == null || newTargetWeight == null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please enter valid numeric values for all fields')),
        );
      return;
    }

    // Derivazione del Goal dinamica basata sul peso inserito
    final Goal derivedGoal = _deriveGoal(newWeight, newTargetWeight);

    final updatedPatient = widget.patient.copyWith(
      weightKg: newWeight,
      heightCm: newHeight,
      activityLevel: selectedActivity,
      targetWeightKg: newTargetWeight,
      goal: derivedGoal,
    );

    // Salvataggio persistente locale
    await PreferenceService.savePatient(updatedPatient);
    await PreferenceService.saveUser(User(
      name: updatedPatient.name,
      surname: updatedPatient.surname,
      birthDate: updatedPatient.birthDate,
      weight: updatedPatient.weightKg,
      height: updatedPatient.heightCm,
      idealWeight: updatedPatient.targetWeightKg ?? 0,
    ));

    // Se il peso corrente è cambiato, aggiungi un'entry nello storico dei pesi
    if (newWeight != widget.patient.weightKg) {
      await PreferenceService.addWeightEntry(
        WeightEntry(
          date: DateTime.now(),
          weight: newWeight,
        ),
      );
    }

    if (mounted) {
      // Aggiorna lo stato globale dell'app e chiudi la pagina
      context.read<PatientState>().setPatient(updatedPatient);
      Navigator.pop(context, true);
    }
  }

  Goal _deriveGoal(double currentWeight, double targetWeight) {
    const threshold = 1.0;
    if (targetWeight < currentWeight - threshold) return Goal.loseWeight;
    if (targetWeight > currentWeight + threshold) return Goal.gainWeight;
    return Goal.maintainWeight;
  }

  @override
  void dispose() {
    heightController.removeListener(_updateRecommendedWeight);
    weightController.dispose();
    heightController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Edit Health Data', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep your physical data updated to track your goals correctly.',
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                // Card contenitore con lo stesso design di PersonalInfoScreen
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Riga Peso e Altezza
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: 'Weight',
                                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                  suffixText: 'kg',
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: 'Height',
                                  prefixIcon: const Icon(Icons.height),
                                  suffixText: 'cm',
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Dropdown Livello di Attività
                        DropdownButtonFormField<ActivityLevel>(
                          value: selectedActivity,
                          decoration: InputDecoration(
                            hintText: 'Activity Level',
                            prefixIcon: const Icon(Icons.fitness_center),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          ),
                          items: ActivityLevel.values.map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level.name[0].toUpperCase() + level.name.substring(1)), // Capitalize
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedActivity = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 18),

                        // Input Peso Obiettivo (Ideal Weight)
                        TextField(
                          controller: targetWeightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Goal Weight',
                            prefixIcon: const Icon(Icons.flag_outlined),
                            suffixText: 'kg',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Box dei consigli dinamici presi dal concetto di bmi_status
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Recommended weight based on BMI: $recommendedWeightRange.',
                                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bottone di Salvataggio
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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