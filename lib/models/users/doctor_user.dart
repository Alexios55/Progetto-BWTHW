import 'package:bwthw_project/models/enums/gender.dart';

import 'user_model.dart';

class DoctorUser extends UserModel {
  final String specialization;
  final String licenseNumber;

  const DoctorUser({
    required super.name,
    required super.surname,
    required super.age,
    required Gender gender,
    required this.specialization,
    required this.licenseNumber,
  }) : super(gender: gender);
}
