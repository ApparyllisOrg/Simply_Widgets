import 'package:flutter/material.dart';

class HoverGrow extends StatefulWidget {
  HoverGrow({required this.child, this.growSize = 1.1, this.duration = 300});

  final Widget child;
  final double growSize;
  final int duration;

  @override
  _HoverGrowState createState() => _HoverGrowState();
}

class _HoverGrowState extends State<HoverGrow> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _onMouseEvent(true),
      onExit: (event) => _onMouseEvent(false),
      child: TweenAnimationBuilder(
        curve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: widget.duration),
        tween: Tween<double>(begin: 1.0, end: scale),
        builder: (BuildContext context, double value, _) {
          return Transform.scale(scale: value, child: widget.child);
        },
      ),
    );
  }

  void _onMouseEvent(bool isHovered) {
    if (mounted) {
      double scaleToUse = isHovered ? widget.growSize : 1.0;
      setState(() {
        scale = scaleToUse;
      });
    }
  }
}
