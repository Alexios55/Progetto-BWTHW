import 'package:bwthw_project/screens/bmi_status.dart';
import 'package:bwthw_project/screens/login_screen.dart';
import 'package:bwthw_project/screens/registration.dart';
import 'package:bwthw_project/screens/start_screen.dart';
import 'package:bwthw_project/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:bwthw_project/screens/personal_info_screen.dart';
import 'package:bwthw_project/screens/splash_screen.dart';
//import 'package:bwthw_project/screens/bmi_status.dart';

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

    return MaterialApp(
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
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/bmi-status': (context) => const BmiStatusScreen(),
      },
    );
  }
}