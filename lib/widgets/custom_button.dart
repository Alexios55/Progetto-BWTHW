// This is a class for standardized buttons on our app
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color; 
  final double width;
  final double height;

  const CustomButton({super.key, 
  required this.text, 
  required this.onPressed,
  this.color = const Color.fromARGB(255, 241, 171, 80),
  this.width = 200,
  this.height = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, 
        style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}