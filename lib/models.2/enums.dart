enum Goal {
  loseWeight,
  maintainWeight,
  gainWeight,
}

extension GoalX on Goal {
  String get label {
    switch (this) {
      case Goal.loseWeight:
        return 'Lose weight';
      case Goal.maintainWeight:
        return 'Maintain weight';
      case Goal.gainWeight:
        return 'Gain weight';
    }
  }

  double get calorieAdjustment {
    switch (this) {
      case Goal.loseWeight:
        return -500;
      case Goal.maintainWeight:
        return 0;
      case Goal.gainWeight:
        return 300;
    }
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  athlete,
}

extension ActivityLevelX on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately active';
      case ActivityLevel.veryActive:
        return 'Very active';
      case ActivityLevel.athlete:
        return 'Athlete';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.athlete:
        return 1.9;
    }
  }
}

enum Gender {
  male,
  female,
  other,
}

extension GenderX on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

