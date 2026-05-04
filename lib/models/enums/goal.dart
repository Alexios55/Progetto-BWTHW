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
