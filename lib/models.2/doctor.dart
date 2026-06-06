import 'enums.dart';
import 'user.dart';

// This class represents a doctor who can follow patients in the application.
class Doctor extends User {
  final Gender gender;
  final String specialization;
  final String licenseNumber;

  Doctor({
    required super.id,
    required super.name,
    super.surname,
    required super.email,
    super.password,
    required this.gender,
    required this.specialization,
    required this.licenseNumber,
  });
}

