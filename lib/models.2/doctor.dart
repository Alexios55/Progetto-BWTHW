import 'enums.dart';
import 'user.dart';

// This class represents a doctor who can follow patients in the application.
class Doctor extends User {
  final Gender gender;
  final String specialization;
  final String licenseNumber;

  Doctor({
    required String id,
    required String name,
    String surname = '',
    required String email,
    String password = '',
    required this.gender,
    required this.specialization,
    required this.licenseNumber,
  }) : super(
          id: id,
          name: name,
          surname: surname,
          email: email,
          password: password,
        );
}

