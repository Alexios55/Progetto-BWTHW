import 'package:flutter/material.dart';

// A animated bar widget that shows the current calorie balance.
// Works exactly like [BmiBar] but maps a signed balance value
// onto a red → green → blue gradient bar.
//
// - Left  (red)  = deficit
// - Center(green)= on target
// - Right (blue) = surplus
//
// Example usage:
// ```dart
// CalorieBalanceBar(
//   balance: -300,       // kcal: negative = deficit, positive = surplus
//   maxRange: 1000,      // value at which the needle hits the edge
// )
// ```

// The balance is calculated thinking to the balance expected in some daily checkpoints

class _Checkpoint {
  final int hour;
  final int minute;
  final double fraction; // Expected fraction of the daily goal cunsumed by that time

  const _Checkpoint(this.hour, this.minute, this.fraction);
}


class CalorieBalanceBar extends StatelessWidget {
  // Signed calorie balance: food - exercise - goal.
  // Negative = deficit, positive = surplus.
  final double consumed;
  final double goal;

  // Absolute value that maps to the full left or right edge.
  // Defaults to 1000 kcal.
  final double maxRange;

  const CalorieBalanceBar({
    super.key,
    required this.consumed,
    required this.goal,
    this.maxRange = 1000,
  });

  // Checkpoints
  static const List<_Checkpoint> _checkPoints = [
    _Checkpoint(0, 0, 0.0),    // midnight 
    _Checkpoint(9, 0, 0.15),   // breakfast
    _Checkpoint(14, 0, 0.45),  // lunch    
    _Checkpoint(19, 0, 0.90),  // dinner  
    _Checkpoint(23, 59, 1.0),  // end of day
  ];

  // Return the expected calories intake in a moment as fraction of the daily goal
  static double _expectedFraction(DateTime now) {
    final nowMinutes = now.hour * 60 + now.minute;

    for (int i = 0; i < _checkPoints.length -1; i++) {
      final a = _checkPoints[i];
      final b = _checkPoints[i+1];
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;

      if (nowMinutes >= aMin && nowMinutes < bMin) {
        final t = (nowMinutes - aMin)/(bMin - aMin);
        return a.fraction + t * (b.fraction - a.fraction);
      }
    }

    return 1.0;
  }

  static String _mealPhaseName(DateTime now) {
    final h = now.hour;
    if (h < 9) return 'before breakfast';
    if (h < 14) return 'after breakfast';
    if (h < 19) return 'after lunch';
    if (h < 23) return 'after dinner';
    return 'end of day';
  }

  // derived values
  double get _expectedNow {
    return _expectedFraction(DateTime.now()) * goal;
  }

  double get _balance => consumed - _expectedNow;
  

  Color get _indicatorColor {
    final norm = (_balance / maxRange).clamp(-1.0, 1.0);
    if (norm < -0.25) return Colors.red;
    if (norm > 0.25) return Colors.blue;
    return Colors.green;
  }

  String get _label {
    final b = _balance;
    final phase = _mealPhaseName(DateTime.now());
    if (b > 200) return '+${b.toStringAsFixed(0)} kcal surplus ($phase)';
    if (b < -200) return '${b.toStringAsFixed(0)} kcal deficit ($phase)';
    return 'On track $phase';
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final balance = _balance;

    // Map balance [-maxRange, +maxRange] → position [0, 1]
    final double position = ((balance / maxRange + 1) / 2).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Gradient bar 
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE53935), // red   — deficit
                Color(0xFF43A047), // green — balanced
                Color(0xFF1E88E5), // blue  — surplus
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Zone labels 
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Deficit',
                style: TextStyle(fontSize: 9, color: Colors.red.shade700)),
              Text('Target',
                style: TextStyle(fontSize: 9, color: Colors.green.shade700)),
              Text('Surplus',
                style: TextStyle(fontSize: 9, color: Colors.blue.shade700)),
            ],
          ),
        ),


        const SizedBox(height: 5),

        // Animated indicator 
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: position),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Align(
              alignment: Alignment(-1 + (value * 2), 0),
              child: Column(
                children: [
                  Text(
                    balance >= 0
                        ? '+${balance.toStringAsFixed(0)}'
                        : balance.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _indicatorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _indicatorColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _indicatorColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 5),

        // Scale 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '-${maxRange.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '0',
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '+${maxRange.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Summary label 
        Center(
          child: Text(
            _label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _indicatorColor,
            ),
          ),
        ),
      ],
    );
  }
}