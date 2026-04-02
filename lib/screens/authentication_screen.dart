import 'package:bwthw_project/widgets/box_text.dart';
import 'package:flutter/material.dart';
import 'package:bwthw_project/widgets/box_text.dart';

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
            ),
            const SizedBox(height: 24),
            BoxText(hintText: 'Email'),
            const SizedBox(height: 24),
            BoxText(hintText: 'Password', obscureText: true),
          ],
        ),
      ),
    );
  }
}