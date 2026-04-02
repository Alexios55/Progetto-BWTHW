import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const routeName = 'registration';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a new account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ), 
            )
          ],
        ),
      ),
    );
  }
}