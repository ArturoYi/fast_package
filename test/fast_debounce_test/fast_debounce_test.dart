import 'package:fast_package/fast_package.dart';
import 'package:test/test.dart';

void main() {
  group("test fast_debounce", () {
    test('onExecute is never invoked for debounced calls', () {
      var onExecute = expectAsync1((String value) {
        expect(value, 'test4');
      }, count: 1);

      FastDebounce.debounce(
        tag: 'test1',
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute('test1'),
      );
      FastDebounce.debounce(
        tag: 'test1',
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute('test2'),
      );
      FastDebounce.debounce(
        tag: 'test1',
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute('test3'),
      );
      FastDebounce.debounce(
        tag: 'test1',
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute('test4'),
      );
    });

    test('onExecute is called within reasonable time of expected delay', () {
      DateTime start = DateTime.now();

      var onExecute = expectAsync0(() {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs =
            (startStopDiff.inMilliseconds.abs() - 1000).abs();
        expect(actualExpectedDiffMs < 100, true); // 100 ms is reasonable
      }, count: 1);

      Duration duration = const Duration(milliseconds: 1000);
      FastDebounce.debounce(
          tag: 'test1', duration: duration, onExecute: () => onExecute());
    });

    test('each call to debounce waits for the set duration', () async {
      DateTime start = DateTime.now();

      var onExecute = expectAsync0(() {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs =
            (startStopDiff.inMilliseconds.abs() - 1100).abs();
        expect(actualExpectedDiffMs < 100, true); // 100 ms is reasonable
      }, count: 1);

      for (int i = 0; i < 5; i++) {
        FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(),
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });

    test(
        'multiple debounce can be run at the same time and will each invoke onExecute',
        () async {
      var onExecute = expectAsync0(() {}, count: 3);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test2',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test3',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
    });

    test('the last call to debounce invokes onExecute', () async {
      var onExecute = expectAsync1((int i) {
        expect(i, 5);
      }, count: 1);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(1));
      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(2));
      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(3));
      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(4));
      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(5));
    });

    test('zero-duration is a valid duration', () async {
      var onExecute = expectAsync0(() {}, count: 1);
      FastDebounce.debounce(
          tag: 'test1', duration: Duration.zero, onExecute: () => onExecute());
    });

    test('count() returns the number of active debouncers', () async {
      int iExpected = 2;

      var onExecute = expectAsync0(
        () {
          expect(FastDebounce.count, iExpected--);
        },
        count: 3,
      );

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test2',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test3',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
    });

    test('cancel() cancels a debouncer', () async {
      var onExecute = expectAsync0(() {}, count: 0);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test2',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test3',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());

      FastDebounce.cancel('test1');
      FastDebounce.cancel('test2');
      FastDebounce.cancel('test3');
    });

    test('cancel() decreases the number of active debouncers', () async {
      int iExpected = 1;

      var onExecute = expectAsync0(() {
        expect(FastDebounce.count, iExpected--);
      }, count: 2);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test2',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test3',
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute());
      FastDebounce.cancel('test1');
    });

    test('calling cancel() on a non-existing tag does\'t cause an exception',
        () async {
      FastDebounce.cancel('non-existing tag');
    });

    test('zero-duration should execute target method synchronously', () async {
      int test = 1;

      var onExecute = expectAsync0(() {
        expect(test--, 1);
      }, count: 1);

      FastDebounce.debounce(
          tag: 'test1', duration: Duration.zero, onExecute: () => onExecute());
      expect(test, 0);
    });

    test('non-zero duration should execute target method asynchronously',
        () async {
      int test = 1;

      var onExecute = expectAsync0(() {
        expect(test, 0);
      }, count: 1);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(microseconds: 1),
          onExecute: () => onExecute());
      expect(test--, 1);
    });

    test('calling fire() should execute the callback immediately', () async {
      var onExecute = expectAsync0(() {}, count: 1);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(seconds: 1),
          onExecute: () => onExecute());
      FastDebounce.fire('test1');
      FastDebounce.cancel('test1');
    });

    test('calling fire() should not remove the debounce timer', () async {
      var onExecute = expectAsync0(() {}, count: 2);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(seconds: 1),
          onExecute: () => onExecute());
      FastDebounce.fire('test1');
    });

    test('cancelAll() cancels and removes all timers', () async {
      var onExecute = expectAsync0(() {}, count: 0);

      FastDebounce.debounce(
          tag: 'test1',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test2',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());
      FastDebounce.debounce(
          tag: 'test3',
          duration: const Duration(milliseconds: 1000),
          onExecute: () => onExecute());

      FastDebounce.cancelAll();
      expect(FastDebounce.count, 0);
    });
  });
}
