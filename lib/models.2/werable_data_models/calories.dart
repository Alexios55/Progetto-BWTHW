import 'package:intl/intl.dart';

class Calories {
  // this class models the single calories data point
  final DateTime time;
  final int value;

  Calories({required this.time, required this.value});

  Calories.fromJson(String date, Map<String, dynamic> json)
    : time = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse('$date ${json["time"]}'),
      value = json["value"];

  @override
  String toString() {
    return 'Calories {timestamp: $time, value: $value}';
  }
}

Map<DateTime, List<Calories>> groupCaloriesByDay(List<Calories> allData) {
  final map = <DateTime, List<Calories>>{};
  for (final c in allData) {
    final day = DateTime(c.time.year, c.time.month, c.time.day);
    map.putIfAbsent(day, () => []).add(c);
  }
  return map;
}

int totalCaloriesUpToNow(Map<DateTime, List<Calories>> grouped, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final list = grouped[today] ?? [];
  return list
      .where((c) => !c.time.isAfter(now))
      .fold<int>(0, (sum, c) => sum + c.value);
}
