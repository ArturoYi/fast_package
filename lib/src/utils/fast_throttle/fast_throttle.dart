library fast_package;

import 'dart:async' show Timer;

/// 定义一个void回调作为参数
/// Defines a void callback as a parameter.
typedef FastThrottleVoidCallback = void Function();

/// 节流操作的内部实现类
/// 用于存储执行回调、后续回调和定时器
/// Internal implementation class for throttle operations.
/// Used to store the onExecute callback, onAfter callback, and the timer.
class _FastThrottleOperation {
  /// 需要在节流开始时执行的回调函数
  /// The callback function to be executed when throttling starts.
  FastThrottleVoidCallback onExecute;

  /// 可选的，在节流结束后执行的回调函数
  /// Optional callback function to be executed after throttling ends.
  FastThrottleVoidCallback? onAfter;

  /// 用于控制节流的定时器
  /// Timer used to control the throttling.
  Timer timer;

  /// 构造函数
  /// [onExecute] 节流开始时执行的回调
  /// [timer] 控制节流的定时器
  /// [onAfter] 节流结束后执行的回调 (可选)
  /// Constructor.
  /// [onExecute] Callback to execute when throttling starts.
  /// [timer] Timer to control throttling.
  /// [onAfter] Optional callback to execute after throttling ends.
  _FastThrottleOperation({
    required this.onExecute,
    required this.timer,
    this.onAfter,
  });
}

/// FastThrottle 类提供了一个用于实现节流功能的工具类
/// 节流的主要作用是确保一个函数在指定的时间间隔内最多只执行一次
/// The FastThrottle class provides a utility for implementing throttle functionality.
/// The main purpose of throttling is to ensure that a function is executed at most once within a specified time interval.
class FastThrottle {
  /// 私有构造函数，防止类被实例化
  /// 该类只提供静态方法，不需要创建实例
  /// Private constructor to prevent the class from being instantiated.
  /// This class only provides static methods and does not need to be instantiated.
  FastThrottle._();

  /// 用于存储所有节流操作的Map
  /// key为标识符tag，value为对应的节流操作
  /// A Map to store all throttle operations.
  /// The key is the identifier tag, and the value is the corresponding throttle operation.
  static final Map<String, _FastThrottleOperation> _operations = {};

  /// 核心节流方法
  /// [tag] 用于标识特定的节流操作
  /// [duration] 节流的持续时间
  /// [onExecute] 在节流开始时立即执行的回调函数
  /// [onAfter] 可选的，在节流时间结束后执行的回调函数
  /// 返回值：如果当前tag正在节流中，则返回true；否则返回false，并开始新的节流。
  /// Core throttle method.
  /// [tag] Used to identify a specific throttle operation.
  /// [duration] The duration of the throttle.
  /// [onExecute] The callback function to be executed immediately when throttling starts.
  /// [onAfter] Optional callback function to be executed after the throttle duration ends.
  /// Returns: true if the current tag is already throttling; otherwise, returns false and starts a new throttle.
  static bool throttle({
    required String tag,
    required Duration duration,
    required FastThrottleVoidCallback onExecute,
    FastThrottleVoidCallback? onAfter,
  }) {
    bool check = _operations.containsKey(tag);
    if (check) {
      /// 如果当前tag已存在，表示正在节流中
      /// If the current tag already exists, it means it's currently throttling.
      return true;
    }

    /// 创建新的节流操作
    /// Create a new throttle operation.
    _operations[tag] = _FastThrottleOperation(
      onExecute: onExecute,
      onAfter: onAfter,
      timer: Timer(
        duration,
        () {
          /// 定时器触发时，表示节流时间结束
          /// 取消定时器，移除操作记录，并执行onAfter回调（如果存在）
          /// When the timer triggers, it means the throttle duration has ended.
          /// Cancel the timer, remove the operation record, and execute the onAfter callback (if it exists).
          _operations[tag]?.timer.cancel();
          _FastThrottleOperation? removed = _operations.remove(tag);
          removed?.onAfter?.call();
        },
      ),
    );

    /// 立即执行onExecute回调
    /// Execute the onExecute callback immediately.
    onExecute();
    return false;
  }

  /// 取消指定tag的节流操作
  /// [tag] 要取消的节流操作的标识符
  /// Cancels the throttle operation for the specified tag.
  /// [tag] The identifier of the throttle operation to cancel.
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// 取消所有正在进行的节流操作
  /// 会清理所有定时器和操作记录
  /// Cancels all ongoing throttle operations.
  /// This will clear all timers and operation records.
  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  /// 获取当前正在进行的节流操作数量
  /// 返回节流操作Map的长度
  /// Gets the number of currently ongoing throttle operations.
  /// Returns the length of the throttle operations Map.
  static int get count => _operations.length;
}
