import 'package:flutter/material.dart';
// This is a class to insert a box where the user can insert text, such as email and password
class BoxText extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final double width;
  final double height;


  const BoxText({
    super.key, 
    required this.hintText, 
    this.obscureText = false,
    this.width = 600,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField( 
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
}
}
