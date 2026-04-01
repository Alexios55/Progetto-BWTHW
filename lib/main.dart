import 'package:bwthw_project/screens/authentication_screen.dart';
import 'package:bwthw_project/screens/welcome_screen.dart';
import 'package:bwthw_project/screens/registration.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
   
}//main

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:'/welcome',
      routes: {
        '/welcome':(context) => WelcomeScreen(),
        '/auth':(context) => AuthScreen(),
        '/registration':(context) => RegistrationScreen(),
      },
    );
  }
}

