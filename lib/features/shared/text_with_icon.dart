import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget {
  const TextWithIcon({
    super.key,
    required this.icon,
    required this.text,
  });

  final Widget icon;
  final Text text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        Padding(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: text,
        ),
      ],
    );
  }
}
