import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  void Function()? onPressed;
  final String text;
  CustomButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff386BF6),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Container(
          width: 260,
          height: 50,
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
        ));
  }
}
