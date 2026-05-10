// This class represents a generic user of the application.
class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String password;
  final DateTime birthDate;
  final double weight;
  final double height;
  final double idealWeight;

  User({
    this.id = '',
    required this.name,
    this.surname = '',
    this.email = '',
    this.password = '',
    DateTime? birthDate,
    this.weight = 0,
    this.height = 0,
    this.idealWeight = 0,
  }) : birthDate = birthDate ?? DateTime(2000);

  String get fullName => '$name $surname'.trim();

  int get age {
    final today = DateTime.now();
    var years = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      years--;
    }

    return years;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'height': height,
      'idealWeight': idealWeight,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      birthDate: DateTime.tryParse(map['birthDate'] ?? '') ?? DateTime(2000),
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      idealWeight: (map['idealWeight'] ?? 0).toDouble(),
    );
  }
}


