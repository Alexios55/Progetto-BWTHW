import 'package:intl/intl.dart';

class Steps{
  final DateTime time;
  final int value;

  Steps({required this.time, required this.value});

  Steps.fromJson(String date, Map<String, dynamic> json) :
      time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
      value = int.parse(json["value"]);

  @override
  String toString() {
    return 'Steps(time: $time, value: $value)';
  }
}

Map<DateTime, List<Steps>> groupStepsByDay(List<Steps> allData) {
  final map = <DateTime, List<Steps>>{};
  for (final s in allData) {
    final day = DateTime(s.time.year, s.time.month, s.time.day);
    map.putIfAbsent(day, () => []).add(s);
  }
  return map;
}

int totalStepsUpToNow(Map<DateTime, List<Steps>> grouped, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final list = grouped[today] ?? [];
  return list
      .where((s) => !s.time.isAfter(now))
      .fold<int>(0, (sum, s) => sum + s.value);
}