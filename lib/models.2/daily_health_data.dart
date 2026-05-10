class DailyHealthData {
  final int steps;
  final double activeCaloriesBurned;
  final int heartRate;
  final int systolicPressure;
  final int diastolicPressure;

  const DailyHealthData({
    required this.steps,
    required this.activeCaloriesBurned,
    required this.heartRate,
    required this.systolicPressure,
    required this.diastolicPressure,
  });

  const DailyHealthData.empty()
      : steps = 0,
        activeCaloriesBurned = 0,
        heartRate = 0,
        systolicPressure = 0,
        diastolicPressure = 0;
}

