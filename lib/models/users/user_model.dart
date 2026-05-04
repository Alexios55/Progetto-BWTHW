import 'package:bwthw_project/models/enums/gender.dart';

class UserModel {
  final String name;
  final String surname;
  final int age;
  final Gender gender;

  const UserModel({
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
  });

  String get fullName => '$name $surname'.trim();
}

@Deprecated('Use UserModel instead.')
class UserMode extends UserModel {
  const UserMode({
    required super.name,
    required super.surname,
    required super.age,
    required super.gender,
  });
}
