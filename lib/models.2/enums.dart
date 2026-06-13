import 'package:flutter/material.dart';

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

enum MealType {
  breakfast,       
  morningSnack,   
  lunch,          
  afternoonSnack,  
  dinner, 
}

extension MealTypeExtension on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:      return 'Breakfast';
      case MealType.morningSnack:   return 'Morning snack';
      case MealType.lunch:          return 'lunch';
      case MealType.afternoonSnack: return 'Afternoon snack';
      case MealType.dinner:         return 'Dinner';
    }
  }
 
  // Returns the MealType matching the current time of day.
  static MealType current() {
    final hour = DateTime.now().hour;
    if (hour >= 6  && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 12) return MealType.morningSnack;
    if (hour >= 12 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 19) return MealType.afternoonSnack;
    return MealType.dinner; // 19:00 – 05:59
  }
}
 
enum FoodCategory {
  dairy,
  juicesAndSweeteners,
  bakeryAndCereals,
  meat,
  fish,
  eggs,
  curedMeats,
  cheese,
  fruit,
  vegetables,
  legumes,
  fatsAndSpreads,
  nuts,
  preparedFoods,
}
