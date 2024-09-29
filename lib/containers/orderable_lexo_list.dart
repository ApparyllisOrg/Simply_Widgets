import 'package:flutter/material.dart';
import 'package:simply_widgets/buttons/drag_handle.dart';
import 'package:simply_widgets/containers/reorderable_list_view.dart';
import 'package:simply_widgets/utils/simplified_lexo.dart';

typedef OrderableStringCallback<T> = String Function(T data);

class OrderableLexoList<T> extends StatefulWidget {
  OrderableLexoList(
      {super.key, required this.getWidget, required this.updatedOrder, required this.data, required this.getKey, required this.getRank});

  final List<T> data;

  final Widget Function(T) getWidget;
  final String Function(T) getKey;
  final String Function(T) getRank;
  final Function(T, String) updatedOrder;

  @override
  OrderableLexoListState createState() => OrderableLexoListState<T>();
}

class OrderableLexoListState<T> extends State<OrderableLexoList<T>> {
  late List<T> _list = [];

  @override
  void initState() {
    super.initState();

    _list = widget.data;
  }

  bool setup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (setup) {
      return;
    }

    setup = true;

    attemptReassign();
  }

  void attemptReassign() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final List<String> foundRanks = [];

      bool requiresReassignment = false;

      for (int i = 0; i < _list.length; ++i) {
        final String rank = widget.getRank(_list[i]);

        // If we have a long rank, rebalance everything, we shouldn't reach this unless people have 100s of orderable items, in which case we can make this smarter.
        if (rank.length > 10) {
          requiresReassignment = true;
          break;
        }
        if (foundRanks.contains(rank)) {
          requiresReassignment = true;
          break;
        } else {
          foundRanks.add(rank);
        }
      }

      _list.sort((a, b) => widget.getRank(a).compareTo(widget.getRank(b)));

      if (requiresReassignment) {
        List<SimplyLexo> lexoItems = [];

        _list.forEach((item) => lexoItems.add(SimplyLexo(widget.getRank(item), id: widget.getKey(item))));

        List<SimplyLexo> balancedLexoItems = SimplyLexo.balance(lexoItems);

        balancedLexoItems.forEach((item) => widget.updatedOrder(_list.firstWhere((test) => widget.getKey(test) == item.id), item.getFullRank()));
      }
    });
  }

  void onOrderChanged(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // Workaround https://github.com/flutter/flutter/issues/24786
      newIndex--;
    }

    final T previousBucketAtLocation = _list[newIndex];
    final T movedBucket = _list[oldIndex];

    final SimplyLexo previousBucketRank = SimplyLexo(widget.getRank(previousBucketAtLocation));

    SimplyLexo newRank;
    if (newIndex > oldIndex) {
      if (newIndex == _list.length - 1) {
        newRank = previousBucketRank;

        final T previousPreviousBucketAtLocation = _list[newIndex - 1];

        final SimplyLexo previousPreviousBucketRank = SimplyLexo(widget.getRank(previousPreviousBucketAtLocation));

        SimplyLexo betweenLastRank = previousPreviousBucketRank.middle(previousBucketRank);

        widget.updatedOrder(previousBucketAtLocation, betweenLastRank.getFullRank());
      } else {
        final T previousNextBucketAtLocation = _list[newIndex + 1];
        newRank = previousBucketRank.middle(SimplyLexo(widget.getRank(previousNextBucketAtLocation)));
      }
    } else {
      if (newIndex == 0) {
        newRank = previousBucketRank;

        final T previousNextBucketAtLocation = _list[newIndex + 1];
        SimplyLexo betweenLastRank = previousBucketRank.middle(SimplyLexo(widget.getRank(previousNextBucketAtLocation)));

        widget.updatedOrder(previousBucketAtLocation, betweenLastRank.getFullRank());
      } else {
        final T previousPreviousBucketAtLocation = _list[newIndex - 1];
        newRank = SimplyLexo(widget.getRank(previousPreviousBucketAtLocation)).middle(previousBucketRank);
      }
    }

    widget.updatedOrder(movedBucket, newRank.getFullRank());

    setState(() {});
  }

  Widget getProxyDecorator(Widget widget, int value, Animation<double> anim) {
    return DragHandle(widget: widget, value: value, anim: anim);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListViewWithoutMergedSemantics.builder(
      primary: true,
      proxyDecorator: getProxyDecorator,
      buildDefaultDragHandles: false,
      itemCount: _list.length,
      itemBuilder: (context, index) =>
          ReorderableDelayedDragStartListener(key: Key(widget.getKey(_list[index])), index: index, child: widget.getWidget(_list[index])),
      onReorder: onOrderChanged,
    );
  }
}
