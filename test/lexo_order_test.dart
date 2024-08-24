import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply_widgets/containers/orderable_lexo_list.dart';
import 'package:simply_widgets/utils/simplified_lexo.dart';

class TestDataClass {
  TestDataClass(this.order);

  String order;
}

void main() {
  testWidgets('Test lexo simple ordering functionality', (tester) async {

  print('============ TEST SMALL DATA SET =============');

  {
      List<SimplyLexo> testData = [
        SimplyLexo("0|000000:"),
        SimplyLexo("0|hzzzzz:"),
        SimplyLexo("0|qzzzzz:"),
        SimplyLexo("0|vhzzzz:"),
        SimplyLexo("0|xqzzzz:"),
        SimplyLexo("0|yvhzzz:"),
        SimplyLexo("0|zfqzzz:"),
        SimplyLexo("0|zpvhzz:"),
        SimplyLexo("0|zuxqzz:"),
        SimplyLexo("0|zxgvhz:"),
        SimplyLexo("0|zyqfqz:"),
        SimplyLexo("0|zzd7vh:"),
        SimplyLexo("0|zzolxq:"),
        SimplyLexo("0|zzuayu:"),
        SimplyLexo("0|zzx5he:"),
        SimplyLexo("0|zzykqo:"),
        SimplyLexo("0|zzzadb:"),
        SimplyLexo("0|yvhzzz:"),
        SimplyLexo("0|zzzn6n:"),
        SimplyLexo("0|zzztlb:"),
        SimplyLexo("0|zzzwsn:"),
        SimplyLexo("0|zzzyeb:"),
        SimplyLexo("0|zzzz75:"),
        SimplyLexo("0|zzzzlk:"),
        SimplyLexo("0|zzzzsr:"),
        SimplyLexo("0|zzzzwd:"),
        SimplyLexo("0|zzzzy6:"),
        SimplyLexo("0|zzzzzi:"),
        SimplyLexo("0|zzzzzq:"),
        SimplyLexo("0|zzzzzu:"),
        SimplyLexo("0|zzzzzw:"),
        SimplyLexo("0|zzzzzx:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzy:"),
        SimplyLexo("0|zzzzzz:")
      ];

      List<SimplyLexo> balancedData =  SimplyLexo.balance(testData);

      List<SimplyLexo> foundData = [];

      // Check if we find any duplicates
      for (int i = 0; i < balancedData.length; ++i) {
        SimplyLexo data = balancedData[i];

        final bool duplicateFound = foundData.any((previouslyFoundData) {
          return previouslyFoundData.getFullRank() == data.getFullRank();
        });

        if (duplicateFound) {
          print("${data.getFullRank()} is duplicate");
        }

        expect(duplicateFound, false);

        foundData.add(data);
      }
  }

  print('============ TEST LARGE DATA SET =============');

  {
      List<SimplyLexo> testData = [];

      for (int i = 0; i < 10000; ++i)
      {
        testData.add(SimplyLexo('0|aaaaaa:'));
      }

      List<SimplyLexo> balancedData =  SimplyLexo.balance(testData);

      List<SimplyLexo> foundData = [];

      // Check if we find any duplicates
      for (int i = 0; i < balancedData.length; ++i) {
        SimplyLexo data = balancedData[i];

        final bool duplicateFound = foundData.any((previouslyFoundData) {
          return previouslyFoundData.getFullRank() == data.getFullRank();
        });

        if (duplicateFound) {
          print("${data.getFullRank()} is duplicate");
        }

        expect(duplicateFound, false);

        foundData.add(data);
      }

        for (int i = 1; i < balancedData.length; ++i)
        {
            expect(balancedData[i].getFullRank().compareTo(balancedData[i - 1].getFullRank()), 1);
        }
  }
  });
}
