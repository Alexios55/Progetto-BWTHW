import 'package:intl/intl.dart';

class Steps {
  final DateTime time;
  final int value;

  Steps({
    required this.time,
    required this.value,
  });

  factory Steps.fromJson(String date, Map<String, dynamic> json) {
    final String rawTime = json['time']?.toString() ?? '00:00:00';

    final DateTime parsedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date $rawTime');

    final dynamic rawValue = json['value'];

    int parsedValue = 0;

    if (rawValue is int) {
      parsedValue = rawValue;
    } else if (rawValue is double) {
      parsedValue = rawValue.round();
    } else if (rawValue is String) {
      parsedValue = int.tryParse(rawValue) ??
          double.tryParse(rawValue)?.round() ??
          0;
    }

    return Steps(
      time: parsedTime,
      value: parsedValue,
    );
  }

  DateTime get timestamp => time;

  @override
  String toString() {
    return 'Steps(time: $time, value: $value)';
  }
}

Map<DateTime, List<Steps>> groupStepsByDay(List<Steps> allData) {
  final map = <DateTime, List<Steps>>{};

  for (final s in allData) {
    final day = DateTime(
      s.time.year,
      s.time.month,
      s.time.day,
    );

    map.putIfAbsent(day, () => []);
    map[day]!.add(s);
  }

  return map;
}

int totalStepsUpToNow(
  Map<DateTime, List<Steps>> grouped,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final list = grouped[today] ?? [];

  return list
      .where((s) => !s.time.isAfter(now))
      .fold<int>(0, (sum, s) => sum + s.value);
}