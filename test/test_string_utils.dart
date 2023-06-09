import 'package:simply_widgets/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('String Utils', () {
    group('String Utils - Single removal', () {
      test('Test single character removal at start', () {
        const String start = 'Hello';
        const String change = 'ello';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "H");
          expect(result.start, 0);
          expect(result.end, 0);
          expect(result.type, TextChangeType.Removed);
        }
      });

      test('Test single character removal in center', () {
        const String start = 'Hello';
        const String change = 'Helo';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "l");
          expect(result.start, 3);
          expect(result.end, 3);
          expect(result.type, TextChangeType.Removed);
        }
      });

      test('Test single character removal at end', () {
        const String start = 'Hello';
        const String change = 'Hell';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "o");
          expect(result.start, 4);
          expect(result.end, 4);
          expect(result.type, TextChangeType.Removed);
        }
      });
    });

    group('String Utils - Single addition', () {
      test('Test single character addition at start', () {
        const String start = 'Hello';
        const String change = 'aHello';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "a");
          expect(result.start, 0);
          expect(result.end, 0);
          expect(result.type, TextChangeType.Added);
        }
      });

      test('Test single character addition in center', () {
        const String start = 'Hello';
        const String change = 'Helalo';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "a");
          expect(result.start, 3);
          expect(result.end, 3);
          expect(result.type, TextChangeType.Added);
        }
      });

      test('Test single character addition at end', () {
        const String start = 'Hello';
        const String change = 'Helloa';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "a");
          expect(result.start, 5);
          expect(result.end, 5);
          expect(result.type, TextChangeType.Added);
        }
      });
    });

    group('String Utils - Multi removal', () {
      test('Test multi character removal at start', () {
        const String start = 'Hello';
        const String change = 'llo';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "He");
          expect(result.start, 0);
          expect(result.end, 1);
          expect(result.type, TextChangeType.Removed);
        }
      });

      test('Test multi character removal in center', () {
        const String start = 'Hello';
        const String change = 'Heo';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "ll");
          expect(result.start, 2);
          expect(result.end, 3);
          expect(result.type, TextChangeType.Removed);
        }
      });

      test('Test multi character removal at end', () {
        const String start = 'Hello';
        const String change = 'Hel';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "lo");
          expect(result.start, 3);
          expect(result.end, 4);
          expect(result.type, TextChangeType.Removed);
        }
      });
    });

    group('String Utils - Multi addition', () {
      test('Test multi character addition at start', () {
        const String start = 'Hello';
        const String change = 'abHello';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "ab");
          expect(result.start, 0);
          expect(result.end, 1);
          expect(result.type, TextChangeType.Added);
        }
      });

      test('Test multi character addition in center', () {
        const String start = 'Hello';
        const String change = 'Helablo';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "ab");
          expect(result.start, 3);
          expect(result.end, 4);
          expect(result.type, TextChangeType.Added);
        }
      });

      test('Test multi character addition at end', () {
        const String start = 'Hello';
        const String change = 'Helloab';

        final TextChange? result = StringUtils.getDiffBetweenStrings(change, start);

        expect(result, isNot(null));

        if (result != null) {
          expect(result.changedText, "ab");
          expect(result.start, 5);
          expect(result.end, 6);
          expect(result.type, TextChangeType.Added);
        }
      });
    });
  });
}
