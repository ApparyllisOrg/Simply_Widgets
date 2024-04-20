import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key, required this.widget, required this.value, required this.anim});

  final Widget widget;
  final int value;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: DecoratedBox(
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).highlightColor),
          boxShadow: [BoxShadow(spreadRadius: 10 * anim.value, blurRadius: 10 * anim.value, color: Theme.of(context).shadowColor)]),
      child: widget,
    ));
  }
}
