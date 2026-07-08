import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/blood_test_state.dart';
import 'package:bwthw_project/models.2/body_measurement_state.dart';
import 'package:bwthw_project/models.2/weight_state.dart';
import 'package:bwthw_project/models.2/daily_nutrition_state.dart';
import 'package:bwthw_project/models.2/user_temp.dart';
import 'util.dart';
import 'theme.dart';

// Screens principali
import 'package:bwthw_project/screens/splash_screen.dart';
import 'package:bwthw_project/screens/start_screen.dart';
import 'package:bwthw_project/screens/login_screen_with_token.dart';
import 'package:bwthw_project/screens/onboarding/registration.dart';
import 'package:bwthw_project/screens/onboarding/welcome_screen.dart';
import 'package:bwthw_project/screens/onboarding/personal_info_screen.dart';
import 'package:bwthw_project/screens/onboarding/bmi_status.dart';
import 'package:bwthw_project/screens/home_screen.dart';
import 'package:bwthw_project/screens/profile/profile_screen.dart';

// ✅ IMPORT CON AS PREFIX per risolvere il conflitto
import 'package:bwthw_project/screens/inside_dashboard/blood_test_screens/blood_test_screen.dart';
import 'package:bwthw_project/screens/inside_dashboard/blood_test_screens/add_blood_test_screen.dart' as blood;
import 'package:bwthw_project/screens/inside_dashboard/body_measurement_screens/body_measurements_screen.dart';
import 'package:bwthw_project/screens/inside_dashboard/body_measurement_screens/add_body_measurement_screen.dart' as body;
import 'package:bwthw_project/screens/inside_dashboard/suggested_food_screen.dart';
import 'package:bwthw_project/screens/inside_dashboard/burned_calories_screen.dart';
import 'package:bwthw_project/screens/inside_dashboard/consumed_calories_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context,
      "Afacad",
      "Abhaya Libre",
    );

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FoodDiaryDB>(
          create: (context) => FoodDiaryDB(),
        ),
        ChangeNotifierProvider<PatientState>(
          create: (context) => PatientState(),
        ),
        ChangeNotifierProvider<BloodTestState>(
          create: (context) => BloodTestState(),
        ),
        ChangeNotifierProvider<BodyMeasurementState>(
          create: (context) => BodyMeasurementState(),
        ),
        ChangeNotifierProvider<WeightState>(
          create: (context) => WeightState(),
        ),
        ChangeNotifierProvider<DailyNutritionState>(
          create: (context) => DailyNutritionState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'smartDIET',
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.system,
        home: SplashScreen(),
        routes: {
          '/start': (context) => const StartScreen(),
          '/login': (context) => const LoginScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/personal-info': (context) {
            final user = ModalRoute.of(context)!.settings.arguments as UserTemp;
            return PersonalInfoScreen(user: user);
          },
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/blood-tests': (context) => const BloodTestScreen(),
          '/add-blood-test': (context) => const blood.AddBloodTestScreen(),
          '/body-measurements': (context) => const BodyMeasurementsScreen(),
          '/add-body-measurement': (context) => const body.AddBodyMeasurementScreen(),
          '/food-suggestions': (context) => const SuggestedFoodsScreen(),
          '/burned-calories': (context) => const CaloriesBurnedScreen(),
          '/consumed-calories': (context) => const ConsumedScreen(),
        },
      ),
    );
  }
}
