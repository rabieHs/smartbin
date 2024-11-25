import 'package:flutter/material.dart';

class ContainerDataWidget extends StatelessWidget {
  final String title;
  final String image;
  final String value;
  const ContainerDataWidget({
    Key? key,
    required this.title,
    required this.image,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Image.asset(
          "assets/images/$image.png",
          width: 35,
        ),
        Text(value)
      ],
    );
  }
}
