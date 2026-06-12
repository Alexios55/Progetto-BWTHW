class BloodTest {
  final DateTime date;
  final double iron;
  final double calcium;
  final double glucose;
  final double cholesterol;
  final double vitaminD;

  BloodTest({
    required this.date,
    required this.iron,
    required this.calcium,
    required this.glucose,
    required this.cholesterol,
    required this.vitaminD,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'iron': iron,
      'calcium': calcium,
      'glucose': glucose,
      'cholesterol': cholesterol,
      'vitaminD': vitaminD,
    };
  }

  factory BloodTest.fromMap(Map<String, dynamic> map) {
    return BloodTest(
      date: DateTime.parse(map['date']),
      iron: (map['iron'] ?? 0).toDouble(),
      calcium: (map['calcium'] ?? 0).toDouble(),
      glucose: (map['glucose'] ?? 0).toDouble(),
      cholesterol: (map['cholesterol'] ?? 0).toDouble(),
      vitaminD: (map['vitaminD'] ?? 0).toDouble(),
    );
  }
}

