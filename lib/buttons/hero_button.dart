import 'package:flutter/material.dart';

class HeroButton extends StatefulWidget {
  const HeroButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.gradientA,
      required this.gradientB,
      required this.textColor,
      required this.buttonColor});

  final void Function() onPressed;
  final String text;
  final Color buttonColor;
  final Color gradientA;
  final Color gradientB;
  final Color textColor;

  @override
  State<HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<HeroButton> {
  bool bHovered = false;

  void onMouseEnter() {
    setState(() {
      bHovered = true;
    });
  }

  void onMouseExit() {
    setState(() {
      bHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (event) => onMouseEnter(),
        onExit: (event) => onMouseExit(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: AnimatedContainer(
            padding: EdgeInsets.only(left: 80, right: 80, top: 20, bottom: 20),
            decoration: BoxDecoration(
                border: Border.all(
                    color: bHovered ? widget.gradientB : Colors.transparent,
                    width: 3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: bHovered ? 5 : 1,
                      color: Colors.black26,
                      blurRadius: 10)
                ],
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: bHovered
                        ? [widget.gradientA, widget.gradientB]
                        : [widget.buttonColor, widget.buttonColor])),
            child: Text(
              widget.text,
              style: TextStyle(color: widget.textColor),
            ),
            duration: Duration(milliseconds: 100),
          ),
        ));
  }
}
