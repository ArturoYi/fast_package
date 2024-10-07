import 'package:fast_package/use_package.dart';

typedef FastThrottleVoidCallback = void Function();

///
class _FastThrottleOperation {
  FastThrottleVoidCallback onExecute;
  FastThrottleVoidCallback? onAfter;
  Timer timer;
  _FastThrottleOperation({
    required this.onExecute,
    required this.timer,
    this.onAfter,
  });
}

///
class FastThrottle {
  ///不允许外部实例化
  FastThrottle._();

  static final Map<String, _FastThrottleOperation> _operations = {};

  ///
  static bool throttle({
    required String tag,
    required Duration duration,
    required FastThrottleVoidCallback onExecute,
    FastThrottleVoidCallback? onAfter,
  }) {
    bool check = _operations.containsKey(tag);
    if (check) {
      ///节流中
      return true;
    }
    _operations[tag] = _FastThrottleOperation(
      onExecute: onExecute,
      onAfter: onAfter,
      timer: Timer(
        duration,
        () {
          _operations[tag]?.timer.cancel();
          _FastThrottleOperation? removed = _operations.remove(tag);
          removed?.onAfter?.call();
        },
      ),
    );
    onExecute();
    return false;
  }

  ///取消节流
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  ///取消全部节流
  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  ///获取节流数量
  static int get count => _operations.length;
}
