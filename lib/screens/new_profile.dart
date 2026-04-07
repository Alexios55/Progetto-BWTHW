import 'package:bwthw_project/widgets/box_text.dart';
import 'package:flutter/material.dart';

class NewProfile extends StatelessWidget {
  const NewProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Profile'),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BoxText(hintText: 'Name'),
              SizedBox(height: 12),
              BoxText(hintText: 'Surname'),
              SizedBox(height: 12),
              
              BoxText(hintText: 'Email'),
              SizedBox(height: 12),
              BoxText(hintText: 'Password', obscureText: true),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}