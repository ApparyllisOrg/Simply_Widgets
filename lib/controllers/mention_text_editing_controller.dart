import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool _kDebugMentionTextController = kDebugMode && true;

class MentionSyntax {
  MentionSyntax({
    required this.regexpPattern,
    required this.startingCharacter,
  }) {
    regExp = RegExp(regexpPattern);
  }

  // The character the regex pattern starts with, used to more performantly find sections in the text
  final String startingCharacter;

  // The regexp to use to find if the section matches
  final String regexpPattern;

  late RegExp regExp;
}

class _TextMention {
  _TextMention({required this.id, required this.display, required this.start, required this.end});

  final String id;
  final String display;
  int start;
  int end;
}

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

// Text editing controller that can parse mentions
// TODO: Check if changing selection position to be outside of current mention scope should invalidate mentioning
// TODO: Add replace support
class MentionTextEditingController extends TextEditingController {
  MentionTextEditingController({
    required this.mentionSyntaxes,
    required this.onSugggestionChanged,
    super.text,
  }) {
    _init();
  }

  final List<MentionSyntax> mentionSyntaxes;
  final Function(String?) onSugggestionChanged;

  final List<_TextMention> cachedMentions = [];

  String _previousText = '';

  int? _mentionStartingIndex;
  int? _mentionLength;
  String? _mentionStartCharacter;

  @override
  void dispose() {
    removeListener(_onTextChanged);

    super.dispose();
  }

  TextSpan _createSpanForNonMatchingRange(int start, int end) {
    return TextSpan(text: text.substring(start, end));
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> inlineSpans = [];

    final String rawText = text;

    int numCharactersInProcessedText = 0;

    int lastStartingRunStart = 0;
    for (int i = 0; i < rawText.length; ++i) {
      final String character = rawText[i];

      for (final MentionSyntax syntax in mentionSyntaxes) {
        if (character == syntax.regexpPattern) {
          final String subStr = rawText.substring(i, rawText.length);
          final RegExpMatch? match = syntax.regExp.firstMatch(subStr);
          if (match != null) {
            final String? matchedString = match.group(0);

            // Add previous normal inline span
            inlineSpans.add(_createSpanForNonMatchingRange(lastStartingRunStart, i));

            if (matchedString != null) {
              print(matchedString);

              inlineSpans.add(TextSpan(text: matchedString));

              lastStartingRunStart = i + matchedString.length;

              // Jump forward, skip the matched string
              i = i + matchedString.length;
              numCharactersInProcessedText += matchedString.length;
            }
          } else {
            inlineSpans.add(TextSpan(text: syntax.startingCharacter));
            lastStartingRunStart = i + 1;
            numCharactersInProcessedText += 1;
          }
        }
      }
    }

    if (lastStartingRunStart != rawText.length) {
      inlineSpans.add(_createSpanForNonMatchingRange(lastStartingRunStart, rawText.length));
      numCharactersInProcessedText += rawText.length - 1 - lastStartingRunStart;
    }

    if (selection.extentOffset <= 0) {
      selection = TextSelection.collapsed(offset: numCharactersInProcessedText);
    }

    return TextSpan(children: inlineSpans);
  }

  void _init() {
    addListener(_onTextChanged);
    if (text.isNotEmpty) {
      _onTextChanged();
    }
  }

  Future<void> _onTextChanged() async {
    int startDifference = 0;
    int endDifference = 0;

    // If we grew
    if (text.length > _previousText.length) {
      for (int i = 0; i < text.length; ++i) {
        if (_previousText.length - 1 >= i) {
          if (text[i] != _previousText[i]) {
            startDifference = i;
            final String remainingText = text.substring(i, text.length);
            final String remainingPreviousText = _previousText.substring(i, _previousText.length);
            if (remainingText.endsWith(remainingPreviousText)) {
              endDifference = startDifference + remainingText.indexOf(remainingPreviousText);
              break;
            } else {
              endDifference = text.length;
              break;
            }
          }
        } else {
          startDifference = i;
          endDifference = text.length;
          break;
        }
      }

      final String changedText = text.substring(startDifference, endDifference);

      if (_kDebugMentionTextController) {
        print('Inserted [$changedText] starting at index $startDifference and ending at $endDifference');
      }

      _processTextChange(TextChange(
          type: TextChangeType.Added, start: startDifference, end: endDifference, previous: _previousText, current: text, changedText: changedText));
    } else {
      for (int i = 0; i < _previousText.length; ++i) {
        if (text.length - 1 >= i) {
          if (text[i] != _previousText[i]) {
            startDifference = i;
            final String remainingText = text.substring(i, text.length);
            final String remainingPreviousText = _previousText.substring(i, _previousText.length);
            if (remainingPreviousText.endsWith(remainingPreviousText)) {
              endDifference = startDifference + remainingPreviousText.indexOf(remainingText);
              break;
            } else {
              endDifference = text.length;
              break;
            }
          }
        } else {
          startDifference = i;
          endDifference = _previousText.length;
          break;
        }
      }

      final String changedText = _previousText.substring(startDifference, endDifference);

      if (_kDebugMentionTextController) {
        print('Removed [$changedText] starting at index $startDifference and ending at $endDifference');
      }

      _processTextChange(TextChange(
          type: TextChangeType.Removed,
          start: startDifference,
          end: endDifference,
          previous: _previousText,
          current: text,
          changedText: changedText));
    }

    _previousText = text;
  }

  bool isMentioning() => _mentionStartingIndex != null && _mentionLength != null && _mentionStartCharacter != null;

  void _cancelMentioning() {
    _mentionStartingIndex = null;
    _mentionLength = null;
    _mentionStartCharacter = null;
    onSugggestionChanged(null);
  }

  void _processTextChange(TextChange change) {
    // Check if we should stop mentioning
    if (isMentioning()) {
      assert(_mentionLength != null);

      switch (change.type) {
        case TextChangeType.Added:
          {
            // Spaces are considered breakers for mentioning
            if (change.changedText == ' ') {
              _cancelMentioning();
            }
          }
          break;
        case TextChangeType.Removed:
          {
            // If we removed our at sign, chancel mentioning
            if (change.changedText == _mentionStartCharacter) {
              _cancelMentioning();
            }
          }
          break;
        case TextChangeType.Replaced:
          {
            // If we're replacing text we cancel mentioning
            _cancelMentioning();
          }
          break;
      }
    }

    // Change mention length and update suggestions
    {
      if (change.type == TextChangeType.Added) {
        if (isMentioning()) {
          _mentionLength = _mentionLength! + change.changedText.length;
          onSugggestionChanged(change.current.substring(_mentionStartingIndex! + 1, _mentionStartingIndex! + _mentionLength!));
        }
      }

      if (change.type == TextChangeType.Removed) {
        if (isMentioning()) {
          _mentionLength = _mentionLength! - change.changedText.length;
          assert(_mentionLength! >= 0);

          // If we no longer have text after our mention sign then hide suggestions until we start typing again
          if (_mentionLength == 1) {
            onSugggestionChanged(null);
          } else {
            onSugggestionChanged(change.current.substring(_mentionStartingIndex! + 1, _mentionStartingIndex! + _mentionLength!));
          }
        }
      }
    }

    // Check if we should start mentioning
    if (!isMentioning() && change.type == TextChangeType.Added) {
      for (int i = 0; i < mentionSyntaxes.length; ++i) {
        final MentionSyntax syntax = mentionSyntaxes[i];
        if (change.changedText == syntax.startingCharacter) {
          _mentionStartingIndex = change.start;
          _mentionLength = change.start + 1;
          _mentionStartCharacter = syntax.startingCharacter;
          break;
        }
      }
    }

    for (int i = cachedMentions.length - 1; i >= 0; --i) {
      final _TextMention mention = cachedMentions[i];

      // Check for overlaps
      if (mention.start <= change.end && mention.end >= change.start) {
        cachedMentions.removeAt(i);
        return;
      }

      // Not overlapping but we inserted text in front of metions so we need to shift them
      if (mention.start > change.end) {
        mention.start += change.changedText.length;
        mention.end += change.changedText.length;
      }
    }
  }
}
