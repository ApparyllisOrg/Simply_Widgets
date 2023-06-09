// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/foundation.dart';

bool _kDebugStringDiff = kDebugMode && true;

enum TextChangeType { Added, Removed, Replaced }

class TextChange {
  TextChange({required this.type, required this.start, required this.end, required this.previous, required this.current, required this.changedText});

  final TextChangeType type;
  final int start;
  final int end;
  final String previous;
  final String current;
  final String changedText;
}

class StringUtils {
  static TextChange? getDiffBetweenStrings(String current, String previous) {
    if (previous == current) {
      return null;
    }

    int startDifference = 0;
    int endDifference = 0;

    // TODO: Replace support

    // If we grew
    if (current.length > previous.length) {
      for (int i = 0; i < current.length; ++i) {
        if (previous.length - 1 >= i) {
          if (current[i] != previous[i]) {
            startDifference = i;
            final String remainingText = current.substring(i, current.length);
            final String remainingPreviousText = previous.substring(i, previous.length);
            if (remainingText.endsWith(remainingPreviousText)) {
              endDifference = startDifference + remainingText.indexOf(remainingPreviousText);
              break;
            } else {
              endDifference = current.length;
              break;
            }
          }
        } else {
          startDifference = i;
          endDifference = current.length;
          break;
        }
      }

      final String changedText = current.substring(startDifference, endDifference);

      if (_kDebugStringDiff) {
        print('Inserted [$changedText] starting at index $startDifference and ending at $endDifference');
      }

      return TextChange(
          type: TextChangeType.Added, start: startDifference, end: endDifference - 1, previous: previous, current: current, changedText: changedText);
    } else {
      for (int i = 0; i < previous.length; ++i) {
        if (current.length - 1 >= i) {
          if (current[i] != previous[i]) {
            startDifference = i;
            final String remainingText = current.substring(i, current.length);
            final String remainingPreviousText = previous.substring(i, previous.length);
            if (remainingPreviousText.endsWith(remainingPreviousText)) {
              final int startRemainingTextIndex = remainingPreviousText.indexOf(remainingText);
              endDifference = startDifference + startRemainingTextIndex;
              break;
            } else {
              endDifference = current.length;
              break;
            }
          }
        } else {
          startDifference = i;
          endDifference = previous.length;
          break;
        }
      }

      final String changedText = previous.substring(startDifference, endDifference);

      if (_kDebugStringDiff) {
        print('Removed [$changedText] starting at index $startDifference and ending at $endDifference');
      }

      return TextChange(
          type: TextChangeType.Removed,
          start: startDifference,
          end: endDifference - 1,
          previous: previous,
          current: current,
          changedText: changedText);
    }
  }
}
