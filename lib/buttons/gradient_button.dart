import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.startColor,
    required this.endColor,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.labelStyle,
  });

  final void Function() onPressed;
  final String label;
  final Color startColor;
  final Color endColor;
  final TextStyle labelStyle;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        blendMode: BlendMode.overlay,
        shaderCallback: ((bounds) {
          return _shimmerGradient.createShader(bounds);
        }),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
              padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
              backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    begin: begin, end: end, colors: [startColor, endColor])),
            child: Text(
              label,
              style: labelStyle,
            ).padding(horizontal: 50, vertical: 20),
          ),
        ));
  }
}
