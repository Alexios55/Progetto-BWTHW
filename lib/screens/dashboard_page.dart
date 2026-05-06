import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bwthw_project/models/food_diary_db.dart';
import 'package:bwthw_project/models/user.dart';
import 'package:bwthw_project/models/weight_entry.dart';
import 'package:bwthw_project/services/preference_service.dart';

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
  }

  Future<void> _logWeight() async {
    final TextEditingController weightController = TextEditingController();

    final double? newWeight = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Weight'),
          content: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter your current weight',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final double? parsedValue =
                    double.tryParse(weightController.text.replaceAll(',', '.'));

                if (parsedValue == null || parsedValue <= 0) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Weight must be a valid number'),
                      ),
                    );
                  return;
                }

                Navigator.pop(dialogContext, parsedValue);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    weightController.dispose();

    if (newWeight == null) return;

    await PreferenceService.addWeightEntry(
      WeightEntry(
        date: DateTime.now(),
        weight: newWeight,
      ),
    );

    if (user != null) {
      final updatedUser = User(
        name: user!.name,
        surname: user!.surname,
        birthDate: user!.birthDate,
        weight: newWeight,
        height: user!.height,
        idealWeight: user!.idealWeight,
      );

      await PreferenceService.saveUser(updatedUser);
    }

    await _loadDashboardData();
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
          const double baseGoal = 1550;
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
                                            _formatNumber(remainingCalories),
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
                                    _formatNumber(baseGoal),
                                    Colors.grey.shade700,
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    context,
                                    Icons.restaurant,
                                    'Food',
                                    _formatNumber(foodCalories),
                                    colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    context,
                                    Icons.local_fire_department_outlined,
                                    'Exercise',
                                    _formatNumber(exerciseCalories),
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
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}