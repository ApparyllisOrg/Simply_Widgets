import 'package:flutter/material.dart';
import 'package:lexo_rank/lexoRank/lexoRankBucket.dart';
import 'package:simply_widgets/buttons/drag_handle.dart';
import 'package:simply_widgets/containers/reorderable_list_view.dart';
import 'package:lexo_rank/lexo_rank.dart';

typedef OrderableStringCallback<T> = String Function(T data);

class OrderableLexoList<T> extends StatefulWidget {
  
  OrderableLexoList({
  super.key, 
  required this.getWidget,
  required this.updatedOrder, 
  required this.data, 
  required this.getKey, 
  required this.getRank
  });

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

    if (setup)
    {
      return;
    }

    setup = true;

    attemptReassign();
  }

  void attemptReassign()
  {
    WidgetsBinding.instance.addPostFrameCallback((_){

      final List<String> foundRanks = [];

      bool requiresReassignment = false;

      for (int i = 0; i < _list.length; ++i)
      {
        final String rank =  widget.getRank(_list[i]);
        if (foundRanks.contains(rank))
        {
            requiresReassignment = true;
            break;
        }
        else 
        {
          foundRanks.add(rank);
        }
      }

      if (requiresReassignment)
      {
        widget.updatedOrder(_list[0], LexoRank.min().format());
        widget.updatedOrder(_list.last, LexoRank.max(LexoRankBucket.BUCKET_0).format());

        for (int i = 1; i < _list.length - 1; ++i)
          {
            final String rank =  widget.getRank(_list[i - 1]);
            final String lastRank =  widget.getRank(_list.last);
            widget.updatedOrder(_list[i], LexoRank.parse(rank).between(LexoRank.parse(lastRank)).format());
          }
      }
    });

  }

  void onOrderChanged(int oldIndex, int newIndex)
  {
    if (newIndex > oldIndex) {
        // Workaround https://github.com/flutter/flutter/issues/24786
        newIndex--;
    }

    final T previousBucketAtLocation = _list[newIndex];
    final T movedBucket = _list[oldIndex];

    LexoRank newRank;
    if (newIndex > oldIndex)
    {
      if (newIndex == _list.length - 1)
      {
        newRank = LexoRank.parse(widget.getRank(previousBucketAtLocation));
        
        final T previousPreviousBucketAtLocation = _list[newIndex-1];
        final betweenLastRank = LexoRank.parse(widget.getRank(previousPreviousBucketAtLocation)).between(LexoRank.parse(widget.getRank(previousBucketAtLocation)));

        widget.updatedOrder(previousBucketAtLocation, betweenLastRank.format());
      }
      else 
      {
        final T previousNextBucketAtLocation = _list[newIndex+1];
        newRank = LexoRank.parse(widget.getRank(previousBucketAtLocation)).between(LexoRank.parse(widget.getRank(previousNextBucketAtLocation)));
      }
    }
    else 
    {
      if (newIndex == 0)
      {
        newRank = LexoRank.parse(widget.getRank(previousBucketAtLocation));
        
        final T previousNextBucketAtLocation = _list[newIndex+1];
        final betweenLastRank = LexoRank.parse(widget.getRank(previousBucketAtLocation)).between(LexoRank.parse(widget.getRank(previousNextBucketAtLocation)));

        widget.updatedOrder(previousBucketAtLocation, betweenLastRank.format());
      }
      else 
      {
        final T previousPreviousBucketAtLocation = _list[newIndex-1];
        newRank = LexoRank.parse(widget.getRank(previousPreviousBucketAtLocation)).between(LexoRank.parse(widget.getRank(previousBucketAtLocation)));
      }
    }

    widget.updatedOrder(movedBucket, newRank.format());

    attemptReassign();

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
      itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
        key: Key(widget.getKey(_list[index])),
        index: index,
        child: widget.getWidget(_list[index])),
      onReorder: onOrderChanged,);
  }
}