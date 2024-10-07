import 'dart:async';
import 'package:fast_package/fast_rate_limit/fast_rate_limit.dart';
import 'package:test/test.dart';

void main() {
  group("test fast_rate_limit", () {
    /// tearDown,测试完成后清理limit
    tearDown(() async {
      final Completer completer = Completer();
      late Timer tearDownTimer;
      tearDownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (FastRateLimit.count == 0) {
          tearDownTimer.cancel();
          completer.complete();
        }
      });
      return completer.future;
    });

    test(
        "onExecute永远不会只为1个速率受限的呼叫调用 \n onExecute is never invoked for only 1 of the rate limited calls",
        () {
      const String tag = 'naver_tag';
      final onExecute = expectAsync1((String value) {
        expect(value, tag);
      }, count: 2);
      FastRateLimit.rateLimit(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastRateLimit.rateLimit(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastRateLimit.rateLimit(
        tag: tag,
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(tag),
      );
      FastRateLimit.rateLimit(
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

      FastRateLimit.rateLimit(
        tag: 'naver_tag',
        duration: const Duration(milliseconds: 100),
        onExecute: () => onExecute(),
      );
    });

    test(
        "对rateLimit的每个调用仅在rateLimit完成时执行 \n each call to rateLimit only executes if the rateLimit has finished",
        () async {
      DateTime start = DateTime.now();

      final onExecute = expectAsync1((int index) {
        Duration startStopDiff = DateTime.now().difference(start);
        int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
        expect(actualExpectedDiffMs < 10 || actualExpectedDiffMs > 500, true);
        expect(index == 0 || index == 3 || index == 4, true);
      }, count: 3);
      FastRateLimit.rateLimit(
          tag: 'has-finished',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute(0));
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 110));
        FastRateLimit.rateLimit(
          tag: 'has-finished',
          duration: const Duration(milliseconds: 110),
          onExecute: () => onExecute(i),
        );
      }
    });

    test(
        "多个rateLimits可以同时运行，并将各自调用一个Execute \n multiple rateLimits can be run at the same time and will each invoke onExecute",
        () async {
      final onExecute = expectAsync0(() {}, count: 3);

      FastRateLimit.rateLimit(
        tag: 'multiple-1',
        duration: const Duration(milliseconds: 300),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: 'multiple-2',
        duration: const Duration(milliseconds: 300),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: 'multiple-3',
        duration: const Duration(milliseconds: 300),
        onExecute: () => onExecute(),
      );
    });

    test(
        "对rateLimit的第一次和最后一次调用调用onExecute \n the first and last calls to rateLimit invokes onExecute",
        () async {
      const String tag = 'first-call';
      final onExecute = expectAsync1((int i) {}, count: 2);

      for (int i = 0; i < 5; i++) {
        FastRateLimit.rateLimit(
          tag: tag,
          duration: const Duration(milliseconds: 300),
          onExecute: () => onExecute(i),
        );
      }
    });

    test("零持续时间是有效的持续时间 \n zero-duration is a valid duration", () {
      var onExecute = expectAsync0(() {}, count: 1);
      FastRateLimit.rateLimit(
        tag: 'zero-duration',
        duration: Duration.zero,
        onExecute: () => onExecute(),
      );
    });

    test('count() returns the number of active rateLimits', () async {
      var onExecute = expectAsync0(() {}, count: 3);
      expect(FastRateLimit.count, 0);
      FastRateLimit.rateLimit(
          tag: 'count-1',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastRateLimit.count, 1);
      FastRateLimit.rateLimit(
          tag: 'count-2',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastRateLimit.count, 2);
      FastRateLimit.rateLimit(
          tag: 'count-3',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastRateLimit.count, 3);
    });

    test("cancel() cancels a rateLimit", () async {
      final onExecute = expectAsync0(() {}, count: 3);
      const String tagA = 'cancel_1';
      const String tagB = 'cancel_2';
      const String tagC = 'cancel_3';

      expect(FastRateLimit.count, 0);

      FastRateLimit.rateLimit(
        tag: tagA,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: tagB,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: tagC,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );

      expect(FastRateLimit.count, 3);

      FastRateLimit.cancel(tagA);
      FastRateLimit.cancel(tagB);
      FastRateLimit.cancel(tagC);
      expect(FastRateLimit.count, 0);
    });

    test(
        "cancel()减少活动费率限制的数量 \n cancel() decreases the number of active rateLimits",
        () {
      final onExecute = expectAsync0(() {}, count: 3);
      const String tagA = 'cancel_1';
      const String tagB = 'cancel_2';
      const String tagC = 'cancel_3';
      FastRateLimit.rateLimit(
        tag: tagA,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: tagB,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );
      FastRateLimit.rateLimit(
        tag: tagC,
        duration: const Duration(milliseconds: 500),
        onExecute: () => onExecute(),
      );
      expect(FastRateLimit.count, 3);
      FastRateLimit.cancel(tagA);
      expect(FastRateLimit.count, 2);
    });

    test(
        "对不存在的标记调用cancel()不会导致异常 \n calling cancel() on a non-existing tag doesn 't cause an exception",
        () {
      FastRateLimit.cancel('non-existing tag');
    });

    test('cancelAll() cancels and removes all timers', () async {
      final onExecute = expectAsync0(() {}, count: 3);

      FastRateLimit.rateLimit(
          tag: 'cancel-all-1',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastRateLimit.rateLimit(
          tag: 'cancel-all-2',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      FastRateLimit.rateLimit(
          tag: 'cancel-all-3',
          duration: const Duration(milliseconds: 500),
          onExecute: () => onExecute());
      expect(FastRateLimit.count, 3);
      FastRateLimit.cancelAll();
      expect(FastRateLimit.count, 0);
    });
  });
}
