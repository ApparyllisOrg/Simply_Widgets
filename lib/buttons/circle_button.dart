import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  const CircleButton(
      {super.key,
      required this.onPressed,
      required this.fillColor,
      required this.padding,
      required this.icon,
      required this.iconSize});

  final void Function() onPressed;
  final Color fillColor;
  final EdgeInsets padding;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 2.0,
      fillColor: fillColor,
      padding: padding,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: iconSize,
      ),
    );
  }
}
