import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool _kDebugMentionTextController = kDebugMode && true;

// Mention object that store the id, display name and avatarurl of the mention
// You can inherit from this to add your own custom data, should you need to
class MentionObject {
  MentionObject({required this.id, required this.displayName, required this.avatarUrl});

  // id of the mention, should match ^([a-zA-Z0-9]){1,}$
  final String id;
  final String displayName;
  final String avatarUrl;
}

// Mention syntax for determining when to start mentioning and parsing to and from markup
// Final markup text would be Prefix -> StartingCharacter -> Id of mention -> Suffix
class MentionSyntax {
  MentionSyntax({
    required this.startingCharacter,
    required this.missingText,
    this.prefix = '<###',
    this.suffix = '###>',
  }) {
    _mentionRegex = RegExp('($prefix)($startingCharacter)([a-zA-Z0-9]{1,})($suffix)');
  }

  // The character the regex pattern starts with, used to more performantly find sections in the text, needs to be a single character
  final String startingCharacter;

  // The prefix to add to the final markup text per mention of this type
  final String prefix;

  // The suffix to add to the final markup text per mention of this type
  final String suffix;

  // The display name to show when the mention with the specified id no longer exists
  final String missingText;

  late RegExp _mentionRegex;

  RegExp getRegExp() => _mentionRegex;
}

// Local-only class to store mentions currently stored in the string visible to the user
class _TextMention {
  _TextMention({required this.id, required this.display, required this.start, required this.end, required this.syntax});

  final String id;
  final String display;
  final MentionSyntax syntax;
  int start;
  int end;
}

enum _TextChangeType { Added, Removed, Replaced }

class TextChange {
  TextChange({required this.type, required this.start, required this.end, required this.previous, required this.current, required this.changedText});

  final _TextChangeType type;
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
    this.controllerToCopyTo,
    required this.mentionSyntaxes,
    this.onSugggestionChanged,
    required this.mentionBgColor,
    required this.mentionTextColor,
    required this.idToMentionObject,
    super.text,
  }) {
    _init();
  }

  // Unique mention syntaxes, all syntaxes should have a different starting character
  final List<MentionSyntax> mentionSyntaxes;

  // Delegate called when suggestion has changed
  final Function(String?)? onSugggestionChanged;

  // Function to get a mention from an id, used to deconstruct markup on construct
  final MentionObject? Function(String) idToMentionObject;

  // Background color of the text for the mention
  final Color mentionBgColor;

  // Color of the text for the mention
  final Color mentionTextColor;

  // EditingController to copy our text to, used for things like the Autocorrect widget
  TextEditingController? controllerToCopyTo;

  final List<_TextMention> _cachedMentions = [];

  String _previousText = '';

  int? _mentionStartingIndex;
  int? _mentionLength;
  MentionSyntax? _mentionSyntax;

  @override
  void dispose() {
    removeListener(_onTextChanged);

    super.dispose();
  }

  void setMarkupText(String markupText) {
    String deconstructedText = '';

    int lastStartingRunStart = 0;

    for (int i = 0; i < markupText.length; ++i) {
      final String character = markupText[i];

      for (final MentionSyntax syntax in mentionSyntaxes) {
        if (character == syntax.prefix[0]) {
          final String subStr = markupText.substring(i, markupText.length);
          final RegExpMatch? match = syntax.getRegExp().firstMatch(subStr);
          if (match != null) {
            deconstructedText += markupText.substring(lastStartingRunStart, i);

            final String matchedMarkup = match.input.substring(match.start, match.end);
            final String mentionId = match[3]!;
            final MentionObject? mention = idToMentionObject(mentionId);

            final String mentionDisplayName = mention?.displayName ?? syntax.missingText;

            final String insertText = '${syntax.startingCharacter}$mentionDisplayName';

            final int indexToInsertMention = deconstructedText.length;
            final int indexToEndInsertion = indexToInsertMention + insertText.length;

            _cachedMentions
                .add(_TextMention(id: mentionId, display: insertText, start: indexToInsertMention, end: indexToEndInsertion, syntax: syntax));

            deconstructedText += insertText;
            lastStartingRunStart = i + matchedMarkup.length;
          }
        }
      }
    }

    if (lastStartingRunStart != markupText.length) {
      deconstructedText += markupText.substring(lastStartingRunStart, markupText.length);
    }

    _previousText = deconstructedText;
    text = deconstructedText;
  }

  TextSpan _createSpanForNonMatchingRange(int start, int end) {
    return TextSpan(text: text.substring(start, end));
  }

  String getSearchText() {
    if (isMentioning()) {
      return text.substring(_mentionStartingIndex! + 1, _mentionStartingIndex! + _mentionLength!);
    }

    return '';
  }

  String getMarkupText() {
    String finalString = '';
    int lastStartingRunStart = 0;

    for (int i = 0; i < _cachedMentions.length; ++i) {
      final _TextMention mention = _cachedMentions[i];

      final int indexToEndRegular = mention.start;

      if (indexToEndRegular != lastStartingRunStart) {
        finalString += text.substring(lastStartingRunStart, indexToEndRegular);
      }

      final String markupString = '${mention.syntax.prefix}${mention.syntax.startingCharacter}${mention.id}${mention.syntax.suffix}';

      finalString += markupString;

      lastStartingRunStart = mention.end;
    }

    if (lastStartingRunStart < text.length) {
      finalString += text.substring(lastStartingRunStart, text.length);
    }

    return finalString;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> inlineSpans = [];
    int lastStartingRunStart = 0;

    for (int i = 0; i < _cachedMentions.length; ++i) {
      final _TextMention mention = _cachedMentions[i];

      final int indexToEndRegular = mention.start;

      if (indexToEndRegular != lastStartingRunStart) {
        inlineSpans.add(_createSpanForNonMatchingRange(lastStartingRunStart, indexToEndRegular));
      }

      inlineSpans.add(
          TextSpan(text: text.substring(mention.start, mention.end), style: TextStyle(backgroundColor: mentionBgColor, color: mentionTextColor)));

      lastStartingRunStart = mention.end;
    }

    if (lastStartingRunStart < text.length) {
      inlineSpans.add(_createSpanForNonMatchingRange(lastStartingRunStart, text.length));
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
    if (_previousText == text) {
      return;
    }

    int startDifference = 0;
    int endDifference = 0;

    // TODO: Replace support

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
          type: _TextChangeType.Added, start: startDifference, end: endDifference, previous: _previousText, current: text, changedText: changedText));
    } else {
      for (int i = 0; i < _previousText.length; ++i) {
        if (text.length - 1 >= i) {
          if (text[i] != _previousText[i]) {
            startDifference = i;
            final String remainingText = text.substring(i, text.length);
            final String remainingPreviousText = _previousText.substring(i, _previousText.length);
            if (remainingPreviousText.endsWith(remainingPreviousText)) {
              final int startRemainingTextIndex = remainingPreviousText.indexOf(remainingText);
              endDifference = startDifference + startRemainingTextIndex;
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
          type: _TextChangeType.Removed,
          start: startDifference,
          end: endDifference,
          previous: _previousText,
          current: text,
          changedText: changedText));
    }

    _previousText = text;

    if (controllerToCopyTo != null) {
      controllerToCopyTo!.text = text;
    }
  }

  bool guardMentionDeletion = false;
  void insertMention(MentionObject mention) {
    assert(isMentioning());

    final int mentionVisibleTextEnd = _mentionStartingIndex! + mention.displayName.length + 1;

    _cachedMentions.add(_TextMention(
        id: mention.id, display: mention.displayName, start: _mentionStartingIndex!, end: mentionVisibleTextEnd, syntax: _mentionSyntax!));

    final int mentionStart = _mentionStartingIndex!;
    final int mentionEnd = _mentionStartingIndex! + _mentionLength!;
    final String startChar = _mentionSyntax!.startingCharacter;

    _cancelMentioning();

    guardMentionDeletion = true;
    _previousText = text.replaceRange(mentionStart, mentionEnd, '$startChar${mention.displayName}');
    text = _previousText;
    guardMentionDeletion = false;

    selection = TextSelection.collapsed(offset: mentionVisibleTextEnd, affinity: TextAffinity.upstream);

    _sortMentions();
  }

  bool isMentioning() => _mentionStartingIndex != null && _mentionLength != null && _mentionSyntax != null;

  void _sortMentions() {
    _cachedMentions.sort((_TextMention a, _TextMention b) {
      return a.start - b.start;
    });
  }

  void _cancelMentioning() {
    _mentionStartingIndex = null;
    _mentionLength = null;
    _mentionSyntax = null;

    if (onSugggestionChanged != null) {
      onSugggestionChanged!(null);
    }
  }

  void _processTextChange(TextChange change) {
    // Check if we should stop mentioning
    if (isMentioning()) {
      assert(_mentionLength != null);

      switch (change.type) {
        case _TextChangeType.Added:
          {
            // Spaces are considered breakers for mentioning
            if (change.changedText == ' ') {
              _cancelMentioning();
            }
          }
          break;
        case _TextChangeType.Removed:
          {
            // If we removed our at sign, chancel mentioning
            if (change.changedText == _mentionSyntax!.startingCharacter) {
              _cancelMentioning();
            }
          }
          break;
        case _TextChangeType.Replaced:
          {
            // If we're replacing text we cancel mentioning
            _cancelMentioning();
          }
          break;
      }
    }

    // Change mention length and update suggestions
    {
      if (change.type == _TextChangeType.Added) {
        if (isMentioning()) {
          _mentionLength = _mentionLength! + change.changedText.length;
          if (onSugggestionChanged != null) {
            onSugggestionChanged!(change.current.substring(_mentionStartingIndex! + 1, _mentionStartingIndex! + _mentionLength!));
          }
        }
      }

      if (change.type == _TextChangeType.Removed) {
        if (isMentioning()) {
          _mentionLength = _mentionLength! - change.changedText.length;
          assert(_mentionLength! >= 0);

          // If we no longer have text after our mention sign then hide suggestions until we start typing again
          if (_mentionLength == 1) {
            if (onSugggestionChanged != null) {
              onSugggestionChanged!(null);
            }
          } else {
            if (onSugggestionChanged != null) {
              onSugggestionChanged!(change.current.substring(_mentionStartingIndex! + 1, _mentionStartingIndex! + _mentionLength!));
            }
          }
        }
      }
    }

    // Check if we should start mentioning
    if (!isMentioning() && change.type == _TextChangeType.Added) {
      for (int i = 0; i < mentionSyntaxes.length; ++i) {
        final MentionSyntax syntax = mentionSyntaxes[i];
        if (change.changedText == syntax.startingCharacter) {
          _mentionStartingIndex = change.start;
          _mentionLength = 1;
          _mentionSyntax = syntax;
          break;
        }
      }
    }

    for (int i = _cachedMentions.length - 1; i >= 0; --i) {
      final _TextMention mention = _cachedMentions[i];

      // Check for overlaps
      if (mention.start < change.end && mention.end > change.start) {
        if (!guardMentionDeletion) {
          _cachedMentions.removeAt(i);
        }
      }

      // Not overlapping but we inserted text in front of metions so we need to shift them
      if (mention.start > change.end && change.type == _TextChangeType.Added) {
        mention.start += change.changedText.length;
        mention.end += change.changedText.length;
      }
      // Not overlapping but we removed text in front of metions so we need to shift them
      if (mention.start < change.end && change.type == _TextChangeType.Removed) {
        mention.start -= change.changedText.length;
        mention.end -= change.changedText.length;
      }
    }
  }
}
