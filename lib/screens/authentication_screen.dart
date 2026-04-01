import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = 'auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please, insert your credentials to login',
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