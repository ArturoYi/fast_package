import 'package:fast_package/fast_throttle/fast_throttle.dart';
import 'package:fast_package/use_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("test fast_throttle", () {
    tearDown(() {
      final Completer<void> completer = Completer<void>();
      late Timer tearDownTimer;
      tearDownTimer = Timer(const Duration(milliseconds: 1000), () {
        if (FastThrottle.count == 0) {
          tearDownTimer.cancel();
          completer.complete();
        }
      });
      return completer.future;
    });
    //
    test(
        "对于节流的调用，从不调用onExecute \n onExecute is never invoked for throttled calls",
        () {
      const String tag = "never-id";

      final onExecute = expectAsync1((String value) {
        expect(value, tag);
      }, count: 1);

      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
    });

    test("调用onExecute时没有延迟 \n onExecute is called with no delay", () {
      DateTime start = DateTime.now();
      final onExecute = expectAsync0(() {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
        expect(actualExpectedDiffMs < 10, true); // 10 ms is reasonable
      }, count: 1);
      FastThrottle.throttle(
        tag: "no-delay",
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(),
      );
    });

    //
    test(
        "仅当初始节流完成时，才执行对节流的每次调用 \n each call to throttle only executes if the initial throttle has finish",
        () async {
      const String tag = "has-finished";
      DateTime start = DateTime.now();

      final onExecute = expectAsync1((int index) {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
        expect(actualExpectedDiffMs < 10 || actualExpectedDiffMs > 500, true);
        expect(true, true);
      }, count: 2);

      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(0),
      );

      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 110));
        FastThrottle.throttle(
          tag: tag,
          duration: const Duration(milliseconds: 100),
          onExecute: () => onExecute(i),
        );
      }
    });

    //
    test(
        "多个节流可以同时运行，并且每个节流都会调用一个执行 \n multiple throttles can be run at the same time and will each invoke onExecute",
        () async {
      final onExecute = expectAsync0(() {}, count: 3);
      FastThrottle.throttle(
          tag: 'multiple-1',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: 'multiple-2',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: 'multiple-3',
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute());
    });

    test(
        "对throttle的第一次调用调用onExecute \n the first call to throttle invokes onExecute",
        () {
      String tag = "first-call";
      final onExecute = expectAsync1((int i) {
        expect(i, 1);
      }, count: 1);
      FastThrottle.throttle(
        tag: 'first-call',
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(1),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(1),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(2),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(3),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(4),
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(5),
      );
    });

    test(
        "在节流器完成后调用onAfter(如果指定) \n onAfter (if specified) is invoked after the throttler has finished",
        () {
      String tag = 'first-call';

      DateTime start = DateTime.now();

      final onExecute = expectAsync1((int i) {
        expect(i, 1);
      }, count: 1);

      final onAfter = expectAsync0(() {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs =
            (startStopDiff.inMilliseconds.abs() - 1000).abs();
        expect(actualExpectedDiffMs < 100, true); // 100 ms is reasonable
      }, count: 1);

      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute(1),
        onAfter: onAfter,
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute(1),
        onAfter: onAfter,
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute(1),
        onAfter: onAfter,
      );
      FastThrottle.throttle(
        tag: tag,
        duration: const Duration(milliseconds: 1000),
        onExecute: () => onExecute(1),
        onAfter: onAfter,
      );
    });

    test("零持续时间是有效的持续时间 \n zero-duration is a valid duration", () {
      String tag = 'zero-duration';
      final onExecute = expectAsync0(() {}, count: 1);
      FastThrottle.throttle(
        tag: tag,
        duration: Duration.zero,
        onExecute: () => onExecute(),
      );
    });

    test("count()返回活动节流的数量 \n count() returns the number of active throttles",
        () {
      expect(FastThrottle.count, 0);
      final onExecute = expectAsync0(() {}, count: 3);
      FastThrottle.throttle(
        tag: 'count-1',
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(),
      );
      expect(FastThrottle.count, 1);
      FastThrottle.throttle(
        tag: 'count-2',
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(),
      );
      expect(FastThrottle.count, 2);
      FastThrottle.throttle(
        tag: 'count-3',
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(),
      );
      expect(FastThrottle.count, 3);
    });

    test("cancel()取消节流 \n cancel() cancels a throttle", () {
      String tagA = 'cancel_1';
      String tagB = 'cancel_2';
      String tagC = 'cancel_3';
      final onExecute = expectAsync0(() {}, count: 3);
      expect(FastThrottle.count, 0);
      FastThrottle.throttle(
          tag: tagA,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: tagB,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: tagC,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());

      expect(FastThrottle.count, 3);

      FastThrottle.cancel(tagA);
      expect(FastThrottle.count, 2);
      FastThrottle.cancel(tagB);
      expect(FastThrottle.count, 1);
      FastThrottle.cancel(tagC);
      expect(FastThrottle.count, 0);
    });

    test(
        "cancel()减少活动节流的数量 \n cancel() decreases the number of active throttles",
        () {
      String tagA = 'cancel_1';
      String tagB = 'cancel_2';
      String tagC = 'cancel_3';
      final onExecute = expectAsync0(() {}, count: 3);
      FastThrottle.throttle(
          tag: tagA,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: tagB,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: tagC,
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastThrottle.count, 3);
      FastThrottle.cancel(tagA);
      expect(FastThrottle.count, 2);
    });

    test(
        "对不存在的标记调用cancel()不会导致异常 \n calling cancel() on a non-existing tag doesn't cause an exception",
        () {
      FastThrottle.cancel('non-existing-tag');
    });

    test("cancelAll()取消并删除所有计时器 \n cancelAll() cancels and removes all timers",
        () {
      expect(FastThrottle.count, 0);
      final onExecute = expectAsync0(() {}, count: 3);

      FastThrottle.throttle(
          tag: 'cancelAll_1',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: 'cancelAll_2',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastThrottle.throttle(
          tag: 'cancelAll_3',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastThrottle.count, 3);
      FastThrottle.cancelAll();
      expect(FastThrottle.count, 0);
    });
  });
}
