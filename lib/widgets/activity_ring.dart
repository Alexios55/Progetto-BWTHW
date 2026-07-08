import 'package:flutter/material.dart';
// Circular progress indicator used to display wearable activity metrics
// (calories burned, steps, distance) vs their daily target.

class ActivityRing extends StatelessWidget {
  final double value;
  final double target;
  final String unit;
  final String label;
  final Color color;
  final bool formatInteger;
  final String sublabel;

  const ActivityRing({
    super.key,
    required this.value,
    required this.target,
    required this.unit,
    required this.label,
    required this.color,
    this.formatInteger = false,
    required this.sublabel
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (value / target).clamp(0.0, 1.0);
    final isComplete = value >= target;
    final displayColor = isComplete ? Colors.green.shade500 : color;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatInteger ? _fmtInt(value) : _fmtVal(value),
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
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          sublabel,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 9,
          )
          )

      ],
    );
  }

  String _fmtVal(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 10) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  String _fmtInt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}


















