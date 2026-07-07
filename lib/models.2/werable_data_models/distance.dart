import 'package:intl/intl.dart';

class Distance {
  // this class models the single calories data point
  final DateTime timestamp;
  final int value;

  Distance({required this.timestamp, required this.value});

  Distance.fromJson(String date, Map<String, dynamic> json)
    : timestamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).parse('$date ${json["time"]}'),
      value = int.parse(json["value"]);

  @override
  String toString() {
    return 'Distance {timestamp: $timestamp, value: $value}';
  }
}

Map<DateTime, List<Distance>> groupStepsByDay(List<Distance> allData) {
  final map = <DateTime, List<Distance>>{};
  for (final d in allData) {
    final day = DateTime(d.timestamp.year, d.timestamp.month, d.timestamp.day);
    map.putIfAbsent(day, () => []).add(d);
  }
  return map;
}

int totalDistanceUpToNow(Map<DateTime, List<Distance>> grouped, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final list = grouped[today] ?? [];
  return list
      .where((d) => !d.timestamp.isAfter(now))
      .fold<int>(0, (sum, d) => sum + d.value);
}