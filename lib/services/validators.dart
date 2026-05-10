//This function checks if the weight inserted by the user is valid.
String? validateWeight(double? weight) {
  if (weight == null) {
    return 'Inserisci il peso';
  }

  if (weight <= 0) {
    return 'Il peso deve essere maggiore di 0';
  }

  if (weight > 300) {
    return 'Peso non valido';
  }

  return null;
}//validateWeight

//This function checks if the height inserted by the user is valid.
String? validateHeight(double? height) {
  if (height == null) {
    return 'Inserisci l altezza';
  }

  if (height < 100 || height > 230) {
    return 'Altezza non valida';
  }

  return null;
}//validateHeight

//This function checks if the age inserted by the user is valid.
String? validateAge(int? age) {
  if (age == null) {
    return 'Inserisci l eta';
  }

  if (age < 10 || age > 100) {
    return 'Eta non valida';
  }

  return null;
}//validateAge

//This function checks if the email inserted by the user is valid.
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Inserisci l email';
  }

  if (!email.contains('@')) {
    return 'Email non valida';
  }

  return null;
}//validateEmail
