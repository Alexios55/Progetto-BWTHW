import 'package:intl/intl.dart';

class Distance {
  final DateTime timestamp;

  /// Valore ricevuto dal server Impact.
  /// Dai log sembra essere espresso in centimetri.
  final int value;

  Distance({
    required this.timestamp,
    required this.value,
  });

  factory Distance.fromJson(String date, Map<String, dynamic> json) {
    final String rawTime = json['time']?.toString() ?? '00:00:00';

    final DateTime parsedTimestamp =
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

    return Distance(
      timestamp: parsedTimestamp,
      value: parsedValue,
    );
  }

  DateTime get time => timestamp;

  @override
  String toString() {
    return 'Distance(timestamp: $timestamp, value: $value)';
  }
}

Map<DateTime, List<Distance>> groupDistanceByDay(List<Distance> allData) {
  final map = <DateTime, List<Distance>>{};

  for (final d in allData) {
    final day = DateTime(
      d.timestamp.year,
      d.timestamp.month,
      d.timestamp.day,
    );

    map.putIfAbsent(day, () => []);
    map[day]!.add(d);
  }

  return map;
}

int totalDistanceCmUpToNow(
  Map<DateTime, List<Distance>> grouped,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final list = grouped[today] ?? [];

  return list
      .where((d) => !d.timestamp.isAfter(now))
      .fold<int>(0, (sum, d) => sum + d.value);
}

double totalDistanceKmUpToNow(
  Map<DateTime, List<Distance>> grouped,
  DateTime now,
) {
  final totalCm = totalDistanceCmUpToNow(grouped, now);
  return totalCm / 100000;
}

/// Compatibilità con eventuale codice vecchio
Map<DateTime, List<Distance>> groupStepsByDay(List<Distance> allData) {
  return groupDistanceByDay(allData);
}

/// Compatibilità con eventuale codice vecchio
int totalDistanceUpToNow(
  Map<DateTime, List<Distance>> grouped,
  DateTime now,
) {
  return totalDistanceCmUpToNow(grouped, now);
}