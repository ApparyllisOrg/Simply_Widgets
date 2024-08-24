import 'dart:math';

class SimplyLexo {
  SimplyLexo(String rank, {this.id}) : _rank = rank;

  final String _rank;
  final String? id;

  static SimplyLexo first() => SimplyLexo("0|aaaaaa");
  static SimplyLexo last() => SimplyLexo("0|zzzzzz");

  String getTextPartRank() {
    return _rank.replaceAll("0|", "").replaceAll(":", "");
  }

  String getFullRank() {
    if (_rank.startsWith('0|') && _rank.endsWith(":")) {
      return _rank;
    }

    String fullRank = _rank;

    if (!_rank.startsWith('0|')) {
      fullRank = "0|" + fullRank;
    }

    if (!_rank.endsWith(":")) {
      fullRank = fullRank + ":";
    }

    return fullRank;
  }

  // Characters used for the LexoRank.
  static String _lexo_charset = "abcdefghijklmnopqrstuvwxyz";

  SimplyLexo middle(SimplyLexo other) {
    String ours = getTextPartRank();
    String theirs = other.getTextPartRank();

    if (ours == theirs) {
      return SimplyLexo(ours + "n");
    }

    String lowest = ours.compareTo(theirs) > 0 ? theirs : ours;
    String highest = ours.compareTo(theirs) > 0 ? ours : theirs;

    while (lowest.length != highest.length) {
      if (lowest.length > highest.length) {
        highest += "a";
      } else {
        lowest += "a";
      }
    }

    List<num> firstPositionCodes = [];
    firstPositionCodes.addAll(lowest.codeUnits);
    List<num> secondPositionCodes = [];
    secondPositionCodes.addAll(highest.codeUnits);

    num difference = 0;
    for (num index = firstPositionCodes.length - 1; index >= 0; index--) {
      /// Codes of the elements of positions
      num firstCode = firstPositionCodes[index.round()];
      num secondCode = secondPositionCodes[index.round()];

      /// i.e. ' a < b '
      if (secondCode < firstCode) {
        secondCode += 26;
        secondPositionCodes[(index - 1).round()] -= 1;
      }

      /// formula: x = a * size^0 + b * size^1 + c * size^2
      final num powRes = pow(26, lowest.length - index - 1);
      difference += (secondCode - firstCode) * powRes;
    }
    var newElement = "";
    if (difference <= 1) {
      /// add middle char from alphabet
      newElement = lowest + String.fromCharCode('a'.codeUnits.first + 26 ~/ 2);
    } else {
      difference ~/= 2;
      var offset = 0;
      for (int index = 0; index < lowest.length; index++) {
        final diffInSymbols = difference ~/ pow(26, index) % (26);
        var newElementCode = lowest.codeUnitAt(highest.length - index - 1) + diffInSymbols + offset;
        offset = 0;

        if (newElementCode > 'z'.codeUnits.first) {
          offset++;
          newElementCode -= 26;
        }

        newElement += String.fromCharCode(newElementCode);
      }
      newElement = newElement.split('').reversed.join();
    }
    return SimplyLexo(newElement);
  }

  static List<SimplyLexo> balance(List<SimplyLexo> items) {
    if (items.isEmpty) {
      return items;
    }

    if (items.length == 1) {
      return items;
    }

    List<SimplyLexo> listCopy = List.from(items);
    listCopy.sort((a, b) => a.getTextPartRank().compareTo(b.getTextPartRank()));

    listCopy.first = SimplyLexo('aaaaaa', id: listCopy.first.id);
    listCopy[listCopy.length - 1] = SimplyLexo('zzzzzz', id: listCopy[listCopy.length - 1].id);

    for (int i = 1; i < listCopy.length - 1; ++i) {
      listCopy[i] = SimplyLexo('aaaaaa', id: listCopy[i].id);
    }

    String replaceCharAt(String oldString, int index, String newChar) {
      if (oldString.length == index) {
        return oldString + newChar;
      } else if (oldString.length > index) {
        return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
      }

      return oldString;
    }

    void balanceLayer(List<SimplyLexo> items, int leftIndex, int rightIndex, int depth) {
      // There is no middle if the Entries are only 1 apart.
      if (leftIndex == rightIndex - 1) {
        return;
      }

      // Calculate the center of the two entry indices.
      final int center_index = ((rightIndex.toDouble() + leftIndex.toDouble()) / 2.0).floor();

      // Grab the 2 entries matching the indices.
      final SimplyLexo left_entry = items[leftIndex];
      final SimplyLexo right_entry = items[rightIndex];

      // I don't really know when I should increment the depth.
      // Currently doing that when finding that the left char is the same as the newly found center char.
      // You might want to think about this a bit before blindly implementing it.
      bool increment_depth = false;

      // Loop over the Chars of the ranks from left to right, based on the depth we are in.
      for (int level = 0; level <= depth; ++level) {
        final String leftRank = left_entry.getTextPartRank();
        final String rightRank = right_entry.getTextPartRank();

        // Grab their ranks and the specified level (num char from left, starting at 0).
        final String left_char = leftRank.length <= level ? _lexo_charset[0] : left_entry.getTextPartRank().substring(level, level + 1);
        final String right_char = rightRank.length <= level ? _lexo_charset[0] : right_entry.getTextPartRank().substring(level, level + 1);

        // Find the char index in the charset matching the chars.
        final int left_char_index = _lexo_charset.indexOf(left_char);
        final int right_char_index = _lexo_charset.indexOf(right_char);

        int center_char_index;

        // We encountered a scenario where the char left of us is greater than the one right of us.
        if (left_char_index > right_char_index) {
          // Use the char left of us and assign the lexo_charset center to the next depth.
          center_char_index = left_char_index;
        } else {
          // Calculate the center/middle of the two char indices and grab the new center char.
          center_char_index = ((right_char_index + left_char_index).toDouble() / 2.0).floor();
        }

        final String center_char = _lexo_charset[center_char_index];

        // Add the center char to the center entry's rank.
        items[center_index] = SimplyLexo(replaceCharAt(items[center_index].getTextPartRank(), level, center_char), id: items[center_index].id);

        // left_char == center_char means that we probably sit exactly between two characters, e.g. A and B.
        if (left_char == center_char) {
          // As previously mentioned, assign the center of the whole lexo_charset to the next depth/level,
          // cause otherwise we would be the same rank as the one left of us.
          final int center_index_lexo_charset = ((_lexo_charset.length - 1).toDouble() / 2.0).floor();
          final int center_char_lexo_charset = _lexo_charset.codeUnitAt(center_index_lexo_charset);
          items[center_index] = SimplyLexo(
              replaceCharAt(items[center_index].getTextPartRank(), level + 1, String.fromCharCode(center_char_lexo_charset)),
              id: items[center_index].id);

          increment_depth = true;
        }
      }

      if (increment_depth) {
        depth = depth + 1;
      }

      // Traverse left and right side of the divided range.
      balanceLayer(items, leftIndex, center_index, depth);
      balanceLayer(items, center_index, rightIndex, depth);
    }

    balanceLayer(listCopy, 0, listCopy.length - 1, 0);

    return listCopy;
  }
}
