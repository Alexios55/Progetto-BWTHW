// This is the first screen that the user will see when they open the app, it will have a welcome message and a button to go to the next screen where they will be able to create an account or log in
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const routeName = 'welcome';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome <nome_app>!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Navigate to the auth screen (login)
                Navigator.pushNamed(context, '/auth');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Color(0xFFFAEBD7)
              ),
              child: const Text('Login'),
            ), // Login button
            const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the create new account screen
                  Navigator.pushNamed(context, '/create-account/');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color(0xFFFAEBD7)
                ),
                child: const Text('Create Account'),
              ), // Create account button
          ],
        ),
      ),
    );
  }
}

