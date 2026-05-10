class BodyMeasurementEntry {
  final DateTime date;
  final double chest;
  final double arm;
  final double waist;
  final double hips;
  final double thigh;

  BodyMeasurementEntry({
    required this.date,
    required this.chest,
    required this.arm,
    required this.waist,
    required this.hips,
    required this.thigh,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'chest': chest,
      'arm': arm,
      'waist': waist,
      'hips': hips,
      'thigh': thigh,
    };
  }

  factory BodyMeasurementEntry.fromMap(Map<String, dynamic> map) {
    return BodyMeasurementEntry(
      date: DateTime.parse(map['date']),
      chest: (map['chest'] ?? 0).toDouble(),
      arm: (map['arm'] ?? 0).toDouble(),
      waist: (map['waist'] ?? 0).toDouble(),
      hips: (map['hips'] ?? 0).toDouble(),
      thigh: (map['thigh'] ?? 0).toDouble(),
    );
  }
}