import 'package:flutter/material.dart';

class SeperatedList extends StatelessWidget {
  const SeperatedList(
      {super.key,
      required this.children,
      this.spacing = 10,
      this.hidden,
      this.spaceWidget,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.min});
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final List<Widget?> children;
  final double spacing;
  final bool? hidden;
  final Widget? spaceWidget;

  @override
  Widget build(BuildContext context) {
    if (hidden == true) {
      return const SizedBox.shrink();
    }

    final List<Widget> list = [];
    for (var i = 0; i < children.length; i++) {
      if (children[i] != null) {
        list.add(children[i]!);
        if (children.length - 1 != i) {
          list.add(spaceWidget ??
              SizedBox(
                height: spacing,
              ));
        }
      }
    }

    final Widget listWidget = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: list,
    );

    return listWidget;
  }
}
