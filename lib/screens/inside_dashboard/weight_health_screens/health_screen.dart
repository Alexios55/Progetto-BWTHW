import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/weight_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/widgets/stat_box.dart';
import 'package:bwthw_project/widgets/bmi_bar.dart';
import 'package:bwthw_project/screens/inside_dashboard/weight_health_screens/edit_health_screen.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/user.dart';
import 'package:bwthw_project/widgets/date_input_field.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

// Minimal PreferenceService implementation used by this screen.
class PreferenceService {
  static Future<User?> getUserData() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString('user');
    if (s == null) return null;
    try {
      return User.fromMap(jsonDecode(s));
    } catch (_) {
      return null;
    }
  }

  static Future<void> addWeightEntry(WeightEntry entry) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList('weightHistory') ?? [];
    list.add(jsonEncode(entry.toMap()));
    await sp.setStringList('weightHistory', list);
  }

  static Future<List<WeightEntry>> getWeightEntries() async {
    final sp = await SharedPreferences.getInstance();
    final entries = sp.getStringList('weightHistory') ?? [];
    return entries.map((e) => WeightEntry.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveWeightEntries(List<WeightEntry> entries) async {
    final sp = await SharedPreferences.getInstance();
    final list = entries.map((e) => jsonEncode(e.toMap())).toList();
    await sp.setStringList('weightHistory', list);
  }

  static Future<void> saveUser(User user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('user', jsonEncode(user.toMap()));
  }

  // Placeholder: persist patient if needed by app. No-op to avoid dependency.
  static Future<void> savePatient(dynamic patient) async {
    return;
  }
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<WeightEntry> weightEntries = [];
  bool isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();
    final entries = sp.getStringList('weightHistory') ?? [];

    final loadedWeightEntries = entries.map((e) => WeightEntry.fromMap(jsonDecode(e))).toList();
    loadedWeightEntries.sort((a, b) => a.date.compareTo(b.date));
    final loadedUser = await PreferenceService.getUserData();
    if (!mounted) return;
    setState(() {
      weightEntries = loadedWeightEntries;
      user = loadedUser;
      isLoading = false;
    });
  }

  // Log weight
  Future<void> _logWeight() async {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    // Pre-fill with today's date.
    final now = DateTime.now();
    dateController.text =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    // Holds the date parsed by DateInputField via its callback.
    DateTime? parsedDate = now; 

    final result = await showDialog<({double weight, DateTime date})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Register Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  hintText: 'e.g. 72.5',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 16),
              DateInputField(
                controller: dateController,
                label: 'Date',
                lastDate: DateTime.now(),
                onDateParsed: (date) => parsedDate = date,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final double? parsedWeight = double.tryParse(
                  weightController.text.replaceAll(',', '.')
                );
                if (parsedWeight == null || parsedWeight <= 0) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Weight must be a valid number'),
                      ),
                    );
                  return;
                }
                if (parsedDate == null) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('Please enter a valid date'),
                    ));
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  (weight: parsedWeight, date: parsedDate!),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    weightController.dispose();
    dateController.dispose();

    if (result == null) return;

    await PreferenceService.addWeightEntry(
      WeightEntry(
        date: result.date,
        weight: result.weight,
      ),
    );

    await _loadData();
  
    // Check if the goal has been rached
    final target = user?.idealWeight;
    if (target != null &&
        ((result.weight - target).abs() <= 0.5)) {
        // Goeal Reached
        _showCongratulationsBanner();
        if (mounted) {
        context.read<PatientState>().updateGoal(Goal.maintainWeight);
        await PreferenceService.savePatient(
          context.read<PatientState>().patient!);
        }}
      else if (target != null && context.read<PatientState>().patient?.goal == Goal.maintainWeight && ((result.weight - target).abs() > 0.5)) {
        // Reload goal because no more in mantain interval
        final newGoal = (result.weight - target) > 1.0 ? Goal.loseWeight : Goal.gainWeight;
        if (mounted) {
          context.read<PatientState>().updateGoal(newGoal);
          await PreferenceService.savePatient(context.read<PatientState>().patient!);
          _showGoalResetBanner(newGoal);
        }
      } 
    }
  

  // Delete Last weight
  Future<void> _deleteLastWeight() async {
    if (weightEntries.length <= 1 || user == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete last weight'),
          content: const Text(
            'Do you want to remove the most recent weight entry?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final List<WeightEntry> updatedEntries = await PreferenceService.getWeightEntries();
    updatedEntries.sort((a, b) => a.date.compareTo(b.date));
    if (updatedEntries.length <= 1) return;
    updatedEntries.removeLast();
    await PreferenceService.saveWeightEntries(updatedEntries);

    final updatedUser = User(
      name: user!.name,
      surname: user!.surname,
      birthDate: user!.birthDate,
      weight: updatedEntries.last.weight,
      height: user!.height,
      idealWeight: user!.idealWeight,
    );

    await PreferenceService.saveUser(updatedUser);

    await _loadData();
  }

  // Congratulation banner
  void _showCongratulationsBanner() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Congratulations!'),
          ],
        ),
        content: const Text(
          'You have reached your ideal weight! Your goal is now set to maintain '
          'your weight. If you want to set a new weight goal, you can do so at '
          'any time in your profile page. Keep up the great work!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }

  // Goal reset
  void _showGoalResetBanner(Goal goal) {
  final message = goal == Goal.loseWeight
      ? 'Your weight has gone above your target. Your goal has been updated to lose weight.'
      : 'Your weight has dropped below your target. Your goal has been updated to gain weight.';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.info_outline, color: Colors.orange),
        SizedBox(width: 8),
        Text('Goal Updated'),
      ]),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  // Getting bmi
  // Calculating BMI using the user's weight and height.
  double get bmi {
    if (user == null || user!.weight == null || user!.height == null) {
      return 0.0;
    }
    double weight = user!.weight!;
    double height = user!.height! / 100;

    return weight / (height * height);
  }

  // Determining the physical status based on the BMI value.
  String get status {
    double bmiValue = bmi;

    if (bmiValue < 18.5) {
      return 'Underweight';
    } else if (bmiValue < 25) {
      return 'Normal';
    } else if (bmiValue < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Determinating the colur associated with the physical status.
  Color get statusColor {
    switch (status) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Providing a description for each physical status.
  String get description {
    switch (status) {
      case 'Underweight':
        return 'Your BMI indicates that you are underweight. It is important to ensure you are consuming enough nutrients to support your health. Consider improving your nutrition.';
      case 'Normal':
        return 'Your BMI is within the normal range. Keep up the good work maintaining a healthy lifestyle!';
      case 'Overweight':
        return 'Your BMI indicates that you are overweight. Consider adopting a balanced diet and regular physical activity to improve your health.';
      case 'Obese':
        return 'Your BMI indicates that you are obese. It is advisable to consult with a healthcare professional for personalized guidance on achieving a healthier weight.';
      default:
        return '';
    }
  }

  // Providing a recommended weight range based on the user's height.
  String get recommendedWeight {
    if (user == null || user!.height == null) {
      return '--';
    }
    double height = user!.height! / 100;
    double minWeight = 18.5 * (height * height);
    double maxWeight = 24.9 * (height * height);

    return '${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} kg';
  }
  // Build
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
 
    final patient = context.watch<PatientState>().patient;
    if (patient == null) return const Scaffold(body: Center(child: Text('No data')));
 
    final colorScheme = Theme.of(context).colorScheme;
    final h = patient.heightCm / 100;
    final bmi = patient.weightKg / (h * h);

    final Color bmiColor;
    if (bmi < 18.5) {
      bmiColor = Colors.blue;
    } else if (bmi < 25) {
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiColor = Colors.orange;
    } else {
      bmiColor = Colors.red;
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Weight & Health'),
                    centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 4 StatBox
            Row(
              children: [
                StatBox(
                  label: 'Weight',
                  value: weightEntries.isNotEmpty
                      ? '${_formatNumber(weightEntries.last.weight)} kg'
                      : '${_formatNumber(patient.weightKg)} kg',
                  icon: Icons.monitor_weight,
                ),
                const SizedBox(width: 10),
                StatBox(label: 'Height', value: '${patient.heightCm} cm', icon: Icons.height),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatBox(label: 'Goal', value: '${patient.targetWeightKg ?? '-'} kg', icon: Icons.flag),
                const SizedBox(width: 10),
                StatBox(label: 'Activity', value: patient.activityLevel.label, icon: Icons.fitness_center),
              ],
            ),
            const SizedBox(height: 10),

            // BMI
            Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'BMI Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ]
                      ),
                      const SizedBox(height: 18),
                      BmiBar(
                        bmi: bmi,
                        statusColor: bmiColor),
                    ],
                  ),
                ),
              ),

            // Wheight chart
            _buildWeightCard(context),
  
            const SizedBox(height: 16),  
            
            // Edit button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: patient == null
                    ? null
                    : () async {
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => EditHealthScreen(patient: patient),
                        ));
                        _loadData();
                      },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit health data'),
              ),
            ), 
          
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  // Wheight card
  Widget _buildWeightCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

      if (weightEntries.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Weight Progress',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _logWeight,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Weight'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'No weight history yet.',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

    final List<WeightEntry> sortedEntries = [...weightEntries]
      ..sort((a, b) => a.date.compareTo(b.date));

    final List<FlSpot> spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final List<double> weights = sortedEntries.map((e) => e.weight).toList();

    double minY = weights.reduce(math.min);
    double maxY = weights.reduce(math.max);

    minY = minY - 2;
    maxY = maxY + 2;

    if (minY < 0) {
      minY = 0;
    }

    if ((maxY - minY) < 4) {
      maxY = minY + 4;
    }

    final double currentWeight = sortedEntries.last.weight;
    final double startingWeight = sortedEntries.first.weight;
    final String goalWeight =
        user != null ? '${_formatNumber(user!.idealWeight)} kg' : '--';

    double interval = (maxY - minY) / 4;
    if (interval <= 0) {
      interval = 1;
    }

    final double maxX =
        sortedEntries.length > 1 ? (sortedEntries.length - 1).toDouble() : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight Progress',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your weight over time',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _logWeight,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Weight'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (sortedEntries.length > 1) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _deleteLastWeight,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete Last',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    spots: spots,
                    color: colorScheme.primary,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.10),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: interval,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox.shrink();
                        }

                        if (index == 0 ||
                            index == sortedEntries.length - 1 ||
                            index == sortedEntries.length ~/ 2) {
                          final DateTime date = sortedEntries[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightInfoBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final patient = context.watch<PatientState>().patient;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );  
  }
  static String _formatNumber(double value) => value.toStringAsFixed(1);
}
