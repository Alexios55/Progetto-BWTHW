class InputValidators {
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAge(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Age');
    if (requiredError != null) {
      return requiredError;
    }

    final age = int.tryParse(value!.trim());
    if (age == null) {
      return 'Age must be a whole number';
    }
    if (age < 12 || age > 100) {
      return 'Age must be between 12 and 100';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    return _validatePositiveNumber(
      value,
      fieldName: 'Weight',
      min: 25,
      max: 350,
    );
  }

  static String? validateHeight(String? value) {
    return _validatePositiveNumber(
      value,
      fieldName: 'Height',
      min: 100,
      max: 250,
    );
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Password');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? _validatePositiveNumber(
    String? value, {
    required String fieldName,
    required double min,
    required double max,
  }) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) {
      return requiredError;
    }

    final number = double.tryParse(value!.replaceAll(',', '.').trim());
    if (number == null) {
      return '$fieldName must be a number';
    }
    if (number < min || number > max) {
      return '$fieldName must be between ${min.toInt()} and ${max.toInt()}';
    }
    return null;
  }
}

