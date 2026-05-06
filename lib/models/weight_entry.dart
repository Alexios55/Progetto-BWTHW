class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({
    required this.date,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      date: DateTime.parse(map['date']),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}