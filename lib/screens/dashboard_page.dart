import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bwthw_project/models.2/food_diary_db.dart';
import 'package:bwthw_project/models.2/user.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/weight_entry.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/widgets/date_input_field.dart';
import 'package:bwthw_project/services/calorie_calculator.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/enums.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<WeightEntry> weightEntries = [];
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final loadedEntries = await PreferenceService.getWeightEntries();
    final loadedUser = await PreferenceService.getUserData();

    loadedEntries.sort((a, b) => a.date.compareTo(b.date));

    if (!mounted) return;

    setState(() {
      weightEntries = loadedEntries;
      user = loadedUser;
      isLoading = false;
    });

    // update the weigth in patient for the calculation of calories
    context.read<PatientState>().updateWeight(loadedUser!.weight);
    await PreferenceService.savePatient(
      context.read<PatientState>().patient!,
    );
  }

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
          title: const Text('Log Weight'),
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

    await _loadDashboardData();

    final target = user?.idealWeight;
    if (target != null &&
        ((result.weight - target).abs() <= 0.5)) {
      _showCongratulationsBanner();
      context.read<PatientState>().updateGoal(Goal.maintainWeight);
      await PreferenceService.savePatient(
        context.read<PatientState>().patient!,
      );
    }
  }

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

    final List<WeightEntry> updatedEntries =
        await PreferenceService.getWeightEntries();

    updatedEntries.sort((a, b) => a.date.compareTo(b.date));

    if (updatedEntries.length <= 1) return;

    updatedEntries.removeLast();

    await PreferenceService.saveWeightEntries(updatedEntries);

    final double newCurrentWeight = updatedEntries.last.weight;

    final updatedUser = User(
      name: user!.name,
      surname: user!.surname,
      birthDate: user!.birthDate,
      weight: newCurrentWeight,
      height: user!.height,
      idealWeight: user!.idealWeight,
    );

    await PreferenceService.saveUser(updatedUser);

    await _loadDashboardData();
  }

  // A banner to show up when the user reaches the goal
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
        'You have reached your ideal weight! Your goal is now set to maintain your weight. If you want to set a new weight goal, you can do so at any time in your profile page. Keep up the great work maintaining a healthy lifestyle.',
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Consumer<FoodDiaryDB>(
        builder: (context, foodDiaryDB, child) {
          final patient = context.watch<PatientState>().patient;
          if (patient == null) {
            return const Center(
              child: Text('No user data found. Please complete your profile.'),
            );
          }

          double baseGoal = calculateDailyCalorieGoal(patient);
          const double exerciseCalories = 0;

          double foodCalories = 0;
          for (final entry in foodDiaryDB.entries) {
            foodCalories += entry.calories;
          }

          double remainingCalories = baseGoal - foodCalories + exerciseCalories;
          if (remainingCalories < 0) {
            remainingCalories = 0;
          }

          double progressValue = foodCalories / baseGoal;
          if (progressValue > 1) {
            progressValue = 1;
          }

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calories',
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Remaining = Goal - Food + Exercise',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: SizedBox(
                                  width: 190,
                                  height: 190,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 190,
                                        height: 190,
                                        child: CircularProgressIndicator(
                                          value: 1,
                                          strokeWidth: 20,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.surfaceContainerHighest,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 190,
                                        height: 190,
                                        child: CircularProgressIndicator(
                                          value: progressValue,
                                          strokeWidth: 20,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${_formatNumber(remainingCalories)} kcal',
                                            style: textTheme.displaySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Remaining',
                                            style: textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    context,
                                    Icons.flag_outlined,
                                    'Base Goal',
                                    '${_formatNumber(baseGoal)} kcal',
                                    Colors.grey.shade700,
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    context,
                                    Icons.restaurant,
                                    'Food',
                                    '${_formatNumber(foodCalories)} kcal',
                                    colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    context,
                                    Icons.local_fire_department_outlined,
                                    'Exercise',
                                    '${_formatNumber(exerciseCalories)} kcal',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildWeightCard(context),
                  const SizedBox(height: 24),
                  _buildBloodTestsCard(context),
                  const SizedBox(height: 24),
                  _buildBodyMeasurementsCard(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
          const SizedBox(height: 18),
          Row(
            children: [
              _weightInfoBox(
                context,
                'Start',
                '${_formatNumber(startingWeight)} kg',
                Icons.flag_outlined,
              ),
              const SizedBox(width: 10),
              _weightInfoBox(
                context,
                'Current',
                '${_formatNumber(currentWeight)} kg',
                Icons.monitor_weight_outlined,
              ),
              const SizedBox(width: 10),
              _weightInfoBox(
                context,
                'Goal',
                goalWeight,
                Icons.track_changes_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTestsCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.pushNamed(context, '/blood-tests');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.bloodtype_outlined,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blood Tests',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap here to add and track your blood values.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMeasurementsCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.pushNamed(context, '/body-measurements');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.accessibility_new,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Body Measurements',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Save chest, arm, waist, hips and thigh measurements.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.titleLarge),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }
}