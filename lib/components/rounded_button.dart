import 'package:flutter/material.dart';
import 'package:chat/screens/login_screen.dart';

class RoundedButton extends StatelessWidget {
  void Function() onPressed;
  final String title;
  final Color buttonColor;

  RoundedButton(
      {required this.onPressed,
      required this.title,
      required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
