import 'dart:async' show Timer;

typedef FastRateLimitCallback = void Function();

class _FastRateLimitOperation {
  FastRateLimitCallback? callback;
  FastRateLimitCallback? onAfter;

  Timer timer;

  _FastRateLimitOperation(
    this.timer,
  );
}

class FastRateLimit {
  FastRateLimit._();

  static final Map<String, _FastRateLimitOperation> _operations = {};

  static bool rateLimit({
    required String tag,
    required Duration duration,
    required FastRateLimitCallback onExecute,
    FastRateLimitCallback? onAfter,
  }) {
    bool check = _operations.containsKey(tag);
    if (check) {
      ///限制中
      ///会更新回调
      _operations[tag]?.callback = onExecute;
      _operations[tag]?.onAfter = onAfter;
      return true;
    }
    final rateLimit = _FastRateLimitOperation(
      Timer.periodic(duration, (timer) {
        final _FastRateLimitOperation? operation = _operations[tag];
        if (operation != null) {
          if (operation.callback == null) {
            operation.timer.cancel();
            _operations.remove(tag);
            onAfter?.call();
          } else {
            operation.callback?.call();
            operation.onAfter?.call();
            operation.callback = null;
            operation.onAfter = null;
          }
        }
      }),
    );
    _operations[tag] = rateLimit;
    onExecute();
    return false;
  }

  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  static int get count => _operations.length;
}
