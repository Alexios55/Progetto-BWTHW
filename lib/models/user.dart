class User {
  final String name;
  final String surname;
  final DateTime birthDate;
  final double weight;
  final double height;
  final double idealWeight;

  User({
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.weight,
    required this.height,
    required this.idealWeight,
  });

  // 🔥 calcolo automatico età
  int get age {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
         today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // 🔹 per salvare facilmente
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'height': height,
      'idealWeight': idealWeight,
    };
  }

  // 🔹 per leggere dati salvati
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      surname: map['surname'],
      birthDate: DateTime.parse(map['birthDate']),
      weight: map['weight'],
      height: map['height'],
      idealWeight: map['idealWeight'],
   );
  }
}