
class HourlyWearableData {
  final int hour;
  final int steps;
  final double burnedCalories;
  final double distanceKm;

  const HourlyWearableData({
    required this.hour,
    required this.steps,
    required this.burnedCalories,
    required this.distanceKm,
  });

  String get hourLabel => '${hour.toString().padLeft(2, '0')}:00';

  @override
  String toString() {
    return 'HourlyWearableData(hour: $hourLabel, steps: $steps, burnedCalories: $burnedCalories, distanceKm: $distanceKm)';
  }
}