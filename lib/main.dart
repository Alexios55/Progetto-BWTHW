import 'package:bwthw_project/screens/onboarding/bmi_status.dart';
import 'package:bwthw_project/screens/home_screen.dart';
import 'package:bwthw_project/screens/login_screen.dart';
import 'package:bwthw_project/screens/onboarding/personal_info_screen.dart';
import 'package:bwthw_project/screens/onboarding/registration.dart';
import 'package:bwthw_project/screens/start_screen.dart';
import 'package:bwthw_project/screens/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/food_diary_db.dart';
import 'util.dart';
import 'theme.dart';
import 'package:bwthw_project/models.2/user_temp.dart';
import 'package:bwthw_project/screens/profile_screen.dart';
import 'package:bwthw_project/screens/blood_test_screen.dart';
import 'package:bwthw_project/screens/add_blood_test_screen.dart';  
import 'package:bwthw_project/screens/splash_screen.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/screens/body_measurements_screen.dart';
import 'package:bwthw_project/screens/add_body_measurement_screen.dart';

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
      '/bmi-status': (context) {
        final user = ModalRoute.of(context)!.settings.arguments as UserTemp;
        return BmiStatusScreen(user: user);
      },
      '/home': (context) => const HomeScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/blood-tests': (context) => const BloodTestScreen(),
      '/add-blood-test': (context) => const AddBloodTestScreen(),
      '/body-measurements': (context) => const BodyMeasurementsScreen(),
      '/add-body-measurement': (context) => const AddBodyMeasurementScreen(),
      },
    ),
  );
  }}