import 'package:intl/intl.dart';

class Calories {
  final DateTime timestamp;
  final double value;

  Calories({
    required this.timestamp,
    required this.value,
  });

  factory Calories.fromJson(String date, Map<String, dynamic> json) {
    final String rawTime = json['time']?.toString() ?? '00:00:00';

    final DateTime parsedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date $rawTime');

    final dynamic rawValue = json['value'];

    double parsedValue = 0.0;

    if (rawValue is num) {
      parsedValue = rawValue.toDouble();
    } else if (rawValue is String) {
      parsedValue = double.tryParse(rawValue) ?? 0.0;
    }

    return Calories(
      timestamp: parsedTimestamp,
      value: parsedValue,
    );
  }

  DateTime get time => timestamp;

  @override
  String toString() {
    return 'Calories(timestamp: $timestamp, value: $value)';
  }
}

Map<DateTime, List<Calories>> groupCaloriesByDay(List<Calories> data) {
  final Map<DateTime, List<Calories>> grouped = {};

  for (final entry in data) {
    final day = DateTime(
      entry.timestamp.year,
      entry.timestamp.month,
      entry.timestamp.day,
    );

    grouped.putIfAbsent(day, () => []);
    grouped[day]!.add(entry);
  }

  return grouped;
}

double totalCaloriesUpToNow(
  Map<DateTime, List<Calories>> grouped,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);

  final todayData = grouped[today] ?? [];

  double total = 0.0;

  for (final entry in todayData) {
    if (entry.timestamp.isBefore(now) ||
        entry.timestamp.isAtSameMomentAs(now)) {
      total += entry.value;
    }
  }

  return total;
}