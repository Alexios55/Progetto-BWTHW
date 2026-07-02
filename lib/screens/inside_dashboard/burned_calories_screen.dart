import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/services/calorie_calculator.dart';
import 'package:bwthw_project/services/impact.dart';
import 'package:bwthw_project/models.2/werable_data_models/steps.dart';

class CaloriesBurnedScreen extends StatefulWidget {
  const CaloriesBurnedScreen({super.key});

  @override
  State<CaloriesBurnedScreen> createState() => _CaloriesBurnedScreenState();
}

class _CaloriesBurnedScreenState extends State<CaloriesBurnedScreen> {
  final Impact _impact = Impact();

  double _burnedGoal = 500;
  bool _isLoading = true;

  int _stepToday = 0;
  int caloriesBurned = 0;
  int distance = 0;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await PreferenceService.getBurnedCaloriesGoal();
    if (!mounted) {await totalStepsUpToNow;};
    setState(() {
      _burnedGoal = prefs;
      _isLoading = false;
    });
  }

  Future<void> _editGoal() async {
    final controller =
        TextEditingController(text: _burnedGoal.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set daily burn goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'kcal',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await PreferenceService.saveBurnedCaloriesGoal(result);
      setState(() => _burnedGoal = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Activity & Burn',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
                  ),
        floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
            tooltip: 'Edit burn goal',
            onPressed: _isLoading ? null : _editGoal,
          ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : Consumer2<PatientState, FoodDiaryDB>(
        builder: (context, patientState, foodDiaryDB, _) {
          final patient = patientState.patient;
          final burned = patientState.burnedCalories;  
          final steps = patientState.steps;
          final distanceKm = patientState.distanceKm; // add to PatientState
          final consumedCalories = foodDiaryDB.entries
              .fold<double>(0, (s, e) => s + e.calories);
          final baseGoal = patient != null
              ? calculateDailyCalorieGoal(patient)
              : 2000.0;
          final surplus =
              (consumedCalories - baseGoal).clamp(0.0, double.infinity);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Three rings side by side ─────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActivityRing(
                            value: burned,
                            target: _burnedGoal,
                            unit: 'kcal',
                            label: 'Calories\nburned',
                            color: Colors.orange.shade500,
                            icon: Icons.local_fire_department_outlined,
                            caption:
                                'Goal: ${_burnedGoal.toStringAsFixed(0)} kcal/day',
                          ),
                          _ActivityRing(
                            value: steps.toDouble(),
                            target: 8000,
                            unit: 'steps',
                            label: 'Daily\nsteps',
                            color: Colors.green.shade500,
                            icon: Icons.directions_walk_outlined,
                            caption: 'Goal: 8,000 steps/day',
                            formatInteger: true,
                          ),
                          _ActivityRing(
                            value: distanceKm,
                            target: (steps * 0.00075)
                                .clamp(1.0, double.infinity),
                            unit: 'km',
                            label: 'Distance\ncovered',
                            color: Colors.blue.shade400,
                            icon: Icons.route_outlined,
                            caption:
                                '~${(steps * 0.00075).toStringAsFixed(1)} km from steps',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Context blurb ────────────────────
                      _ContextCard(
                        burned: burned,
                        steps: steps,
                        distanceKm: distanceKm,
                        surplus: surplus,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),

                      const SizedBox(height: 24),

                      // ── Suggestions header ───────────────
                      if (surplus > 0) ...[
                        Text(
                          'Burn off the surplus',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You're ${surplus.toStringAsFixed(0)} kcal over your daily goal. "
                          'Here are some ways to balance it out:',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ] else ...[
                        Text(
                          'Keep moving',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You're within your calorie budget — great work! "
                          'Some activity ideas for the rest of the day:',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Activity suggestion cards ────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activities =
                          _buildActivities(surplus, patient?.weightKg ?? 70);
                      if (index >= activities.length) return null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ActivityCard(
                          activity: activities[index],
                          surplus: surplus,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      );
                    },
                    childCount:
                        _buildActivities(surplus, patient?.weightKg ?? 70)
                            .length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  List<_Activity> _buildActivities(double surplus, double weightKg) {
    // MET-based kcal/min estimates for a ~70kg person, scaled by weight
    final scale = weightKg / 70;
    return [
      _Activity(
        icon: Icons.directions_walk_outlined,
        name: 'Brisk walk',
        color: Colors.green.shade500,
        kcalPerMin: 5.0 * scale,
        description:
            'An easy way to close your rings. A 30-minute walk at a good pace '
            'gets your blood moving without taxing your joints.',
      ),
      _Activity(
        icon: Icons.directions_run_outlined,
        name: 'Running',
        color: Colors.orange.shade500,
        kcalPerMin: 10.5 * scale,
        description:
            'The most efficient calorie burner on this list. Even a short 20-minute '
            'jog makes a noticeable dent in a surplus and boosts your mood for hours.',
      ),
      _Activity(
        icon: Icons.directions_bike_outlined,
        name: 'Cycling',
        color: Colors.blue.shade500,
        kcalPerMin: 8.0 * scale,
        description:
            'Low impact on your joints and easy to sustain for longer sessions. '
            'Great if you want to combine it with your commute or errands.',
      ),
      _Activity(
        icon: Icons.pool_outlined,
        name: 'Swimming',
        color: Colors.cyan.shade500,
        kcalPerMin: 9.0 * scale,
        description:
            'Works every muscle group simultaneously and keeps your heart rate '
            'elevated throughout. Excellent for rest-day active recovery too.',
      ),
      _Activity(
        icon: Icons.fitness_center_outlined,
        name: 'Strength training',
        color: Colors.purple.shade400,
        kcalPerMin: 6.5 * scale,
        description:
            'Burns fewer calories in the moment than cardio, but raises your '
            'resting metabolic rate for up to 48 hours after — a longer-lasting effect.',
      ),
      _Activity(
        icon: Icons.self_improvement_outlined,
        name: 'Yoga / stretching',
        color: Colors.teal.shade400,
        kcalPerMin: 3.5 * scale,
        description:
            'A lighter option when your body needs rest. Improves flexibility, '
            'reduces cortisol (which helps with fat storage), and promotes recovery.',
      ),
    ];
  }
}

// ── ACTIVITY RING ────────────────────────────────────────────────

class _ActivityRing extends StatelessWidget {
  final double value;
  final double target;
  final String unit;
  final String label;
  final Color color;
  final IconData icon;
  final String caption;
  final bool formatInteger;

  const _ActivityRing({
    required this.value,
    required this.target,
    required this.unit,
    required this.label,
    required this.color,
    required this.icon,
    required this.caption,
    this.formatInteger = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (value / target).clamp(0.0, 1.0);
    final isComplete = value >= target;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: colorScheme.outlineVariant.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green.shade500 : color,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 18,
                    color: isComplete ? Colors.green.shade500 : color),
                const SizedBox(height: 2),
                Text(
                  formatInteger
                      ? _formatInt(value)
                      : _formatVal(value),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  unit,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (isComplete)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.check,
                      size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatVal(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 10) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  String _formatInt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

// ── CONTEXT CARD ─────────────────────────────────────────────────

class _ContextCard extends StatelessWidget {
  final double burned;
  final int steps;
  final double distanceKm;
  final double surplus;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ContextCard({
    required this.burned,
    required this.steps,
    required this.distanceKm,
    required this.surplus,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final String message;
    final IconData icon;
    final Color color;

    if (surplus <= 0 && steps >= 8000) {
      icon = Icons.star_outline_rounded;
      color = Colors.green.shade500;
      message =
          'Outstanding day — you\'ve hit your step goal and your calories are in check. '
          'Your body is in a great position to recover and rebuild overnight.';
    } else if (surplus > 0 && burned >= surplus) {
      icon = Icons.check_circle_outline;
      color = Colors.green.shade500;
      message =
          'You\'ve already burned enough to cover today\'s surplus — well done. '
          'Any extra activity from here on contributes to your longer-term fitness.';
    } else if (surplus > 0) {
      icon = Icons.info_outline;
      color = Colors.orange.shade500;
      message =
          'You have a ${surplus.toStringAsFixed(0)} kcal surplus today. '
          'You\'ve covered ${burned.toStringAsFixed(0)} kcal through activity so far — '
          '${(surplus - burned).clamp(0, double.infinity).toStringAsFixed(0)} kcal left to balance out. '
          'Even a short walk can make a real difference.';
    } else {
      icon = Icons.directions_walk_outlined;
      color = colorScheme.primary;
      message =
          'You\'ve walked ${steps.toString()} steps today — '
          '${steps >= 8000 ? 'above' : 'below'} the recommended 8,000. '
          'Studies show that consistent daily movement, even light walking, '
          'has significant long-term cardiovascular benefits.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ACTIVITY MODEL ───────────────────────────────────────────────

class _Activity {
  final IconData icon;
  final String name;
  final Color color;
  final double kcalPerMin;
  final String description;

  const _Activity({
    required this.icon,
    required this.name,
    required this.color,
    required this.kcalPerMin,
    required this.description,
  });
}

// ── ACTIVITY CARD ─────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  final double surplus;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ActivityCard({
    required this.activity,
    required this.surplus,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final minutesNeeded = surplus > 0
        ? (surplus / activity.kcalPerMin).ceil()
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activity.color.withOpacity(0.3)),
            ),
            child: Icon(activity.icon, size: 20, color: activity.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (minutesNeeded != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: activity.color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color: activity.color.withOpacity(0.3)),
                        ),
                        child: Text(
                          '~$minutesNeeded min',
                          style: textTheme.labelSmall?.copyWith(
                            color: activity.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  activity.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (minutesNeeded != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Burns ~${activity.kcalPerMin.toStringAsFixed(0)} kcal/min · '
                    '${surplus.toStringAsFixed(0)} kcal surplus covered in $minutesNeeded min',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}