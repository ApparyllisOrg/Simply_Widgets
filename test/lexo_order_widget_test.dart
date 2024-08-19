import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexo_rank/lexo_rank.dart';
import 'package:simply_widgets/containers/orderable_lexo_list.dart';

class TestDataClass {
  TestDataClass(this.order);

  String order;
}

void main() {
  testWidgets('Test lexo widget ordering functionality', (tester) async {
    GlobalKey<OrderableLexoListState> _lexoState = GlobalKey<OrderableLexoListState>();

    List<TestDataClass> testData = [
      TestDataClass("0|000000:"),
      TestDataClass("0|hzzzzz:"),
      TestDataClass("0|qzzzzz:"),
      TestDataClass("0|vhzzzz:"),
      TestDataClass("0|xqzzzz:"),
      TestDataClass("0|yvhzzz:"),
      TestDataClass("0|zfqzzz:"),
      TestDataClass("0|zpvhzz:"),
      TestDataClass("0|zuxqzz:"),
      TestDataClass("0|zxgvhz:"),
      TestDataClass("0|zyqfqz:"),
      TestDataClass("0|zzd7vh:"),
      TestDataClass("0|zzolxq:"),
      TestDataClass("0|zzuayu:"),
      TestDataClass("0|zzx5he:"),
      TestDataClass("0|zzykqo:"),
      TestDataClass("0|zzzadb:"),
      TestDataClass("0|yvhzzz:"),
      TestDataClass("0|zzzn6n:"),
      TestDataClass("0|zzztlb:"),
      TestDataClass("0|zzzwsn:"),
      TestDataClass("0|zzzyeb:"),
      TestDataClass("0|zzzz75:"),
      TestDataClass("0|zzzzlk:"),
      TestDataClass("0|zzzzsr:"),
      TestDataClass("0|zzzzwd:"),
      TestDataClass("0|zzzzy6:"),
      TestDataClass("0|zzzzzi:"),
      TestDataClass("0|zzzzzq:"),
      TestDataClass("0|zzzzzu:"),
      TestDataClass("0|zzzzzw:"),
      TestDataClass("0|zzzzzx:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzy:"),
      TestDataClass("0|zzzzzz:")
    ];

    Map<String, int> mappedKeys = {};

    for (int i = 0; i < testData.length; ++i) {
      mappedKeys[testData[i].order] = i;
    }

    // The widget automatically reorders upon opening to rid of duplicates
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: OrderableLexoList<TestDataClass>(
            key: _lexoState,
            getWidget: (Object field) => SizedBox(width: 10, height: 30),
            updatedOrder: (TestDataClass data, String newOrder) {
              data.order = newOrder;
            },
            data: testData,
            getKey: (TestDataClass data) => mappedKeys[data.order].toString(),
            getRank: (TestDataClass data) => data.order)));

    List<TestDataClass> foundData = [];

    // Print out the resulting order
    for (int i = 0; i < testData.length; ++i) {
      TestDataClass data = testData[i];
      print(data.order);
    }

    // Check if we find any duplicates
    for (int i = 0; i < testData.length; ++i) {
      TestDataClass data = testData[i];

      final bool duplicateFound = foundData.any((previouslyFoundData) {
        return previouslyFoundData.order == data.order;
      });

      if (duplicateFound) {
        print("${data.order} is duplicate");
      }

      expect(duplicateFound, false);

      foundData.add(data);
    }
  });
}
