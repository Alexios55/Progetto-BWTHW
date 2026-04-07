import 'package:bwthw_project/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:bwthw_project/widgets/box_text.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = 'auth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please, insert your credentials to login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            BoxText(hintText: 'Email'),
            SizedBox(height: 12),
            BoxText(hintText: 'Password', obscureText: true),
            SizedBox(height: 24),
            CustomButton(text: 'Login', onPressed: () {
              // Implement login logic here
            }),
          ],
        ),
      )
      ),
    );
  }
}