library fast_package;

import 'dart:async' show Timer;

/// 定义一个void回调作为参数
/// Defines a void callback as a parameter.
typedef FastRateLimitCallback = void Function();

/// 速率限制操作的内部实现类
/// 用于存储回调函数和定时器
/// Internal implementation class for rate limit operations.
/// Used to store callback functions and the timer.
class _FastRateLimitOperation {
  /// 在速率限制周期内，如果再次触发，则会更新此回调
  /// If triggered again within the rate limit period, this callback will be updated.
  FastRateLimitCallback? callback;

  /// 在速率限制周期结束后，如果之前有更新的回调，则会执行此回调
  /// If there was an updated callback during the rate limit period, this callback will be executed after the period ends.
  FastRateLimitCallback? onAfter;

  /// 用于控制速率限制的周期性定时器
  /// Periodic timer used to control the rate limit.
  Timer timer;

  /// 构造函数
  /// [timer] 控制速率限制的定时器
  /// Constructor.
  /// [timer] Timer to control the rate limit.
  _FastRateLimitOperation(
    this.timer,
  );
}

/// FastRateLimit 类提供了一个用于实现速率限制功能的工具类
/// 速率限制的主要作用是控制一个函数在每个时间窗口内只执行一次，
/// 如果在时间窗口内多次调用，则会缓存最后一次调用，并在下一个时间窗口开始时执行。
/// The FastRateLimit class provides a utility for implementing rate limit functionality.
/// The main purpose of rate limiting is to control a function to execute only once per time window.
/// If called multiple times within a time window, it caches the last call and executes it at the beginning of the next time window.
class FastRateLimit {
  /// 私有构造函数，防止类被实例化
  /// 该类只提供静态方法，不需要创建实例
  /// Private constructor to prevent the class from being instantiated.
  /// This class only provides static methods and does not need to be instantiated.
  FastRateLimit._();

  /// 用于存储所有速率限制操作的Map
  /// key为标识符tag，value为对应的速率限制操作
  /// A Map to store all rate limit operations.
  /// The key is the identifier tag, and the value is the corresponding rate limit operation.
  static final Map<String, _FastRateLimitOperation> _operations = {};

  /// 核心速率限制方法
  /// [tag] 用于标识特定的速率限制操作
  /// [duration] 速率限制的时间窗口大小
  /// [onExecute] 首次调用或在新的时间窗口开始时执行的回调函数
  /// [onAfter] 可选的，在时间窗口结束后，如果期间有新的调用被缓存，则执行此回调
  /// 返回值：如果当前tag正在限制中（即在当前时间窗口内），则返回true；否则返回false，并开始新的速率限制周期。
  /// Core rate limit method.
  /// [tag] Used to identify a specific rate limit operation.
  /// [duration] The size of the rate limit time window.
  /// [onExecute] The callback function to be executed on the first call or at the beginning of a new time window.
  /// [onAfter] Optional callback function to be executed after the time window ends if new calls were cached during the period.
  /// Returns: true if the current tag is currently limited (i.e., within the current time window); otherwise, returns false and starts a new rate limit period.
  static bool rateLimit({
    required String tag,
    required Duration duration,
    required FastRateLimitCallback onExecute,
    FastRateLimitCallback? onAfter,
  }) {
    bool check = _operations.containsKey(tag);
    if (check) {
      /// 如果当前tag已存在，表示正在限制中
      /// 更新回调函数，以便在下一个时间窗口执行最新的调用
      /// If the current tag already exists, it means it's currently limited.
      /// Update the callback functions to execute the latest call in the next time window.
      _operations[tag]?.callback = onExecute;
      _operations[tag]?.onAfter = onAfter;
      return true;
    }

    /// 创建新的速率限制操作
    /// Create a new rate limit operation.
    final rateLimit = _FastRateLimitOperation(
      Timer.periodic(duration, (timer) {
        /// 定时器周期性触发，表示一个时间窗口结束，新的时间窗口开始
        /// When the timer triggers periodically, it means a time window has ended, and a new one begins.
        final _FastRateLimitOperation? operation = _operations[tag];
        if (operation != null) {
          if (operation.callback == null) {
            /// 如果没有缓存的回调 (即在上一个时间窗口内没有新的调用)
            /// 则取消定时器，并移除操作记录
            /// 如果有 onAfter 回调，则执行它 (通常用于清理或最终状态更新)
            /// If there is no cached callback (i.e., no new calls in the previous time window),
            /// cancel the timer and remove the operation record.
            /// If there is an onAfter callback, execute it (usually for cleanup or final state update).
            operation.timer.cancel();
            _operations.remove(tag);
            // 注意：这里的 onAfter 应该是最初传入的 onAfter，而不是 operation.onAfter
            // 因为 operation.onAfter 可能在限制期间被更新。
            // 但根据现有逻辑，如果 callback 为 null，意味着没有新的 onExecute，
            // 此时执行最初的 onAfter 可能是期望行为，表示一个完整的“无新请求”周期结束。
            // 然而，更常见的速率限制模式可能是在有实际执行时才调用 onAfter。
            // 这里的逻辑是：如果一个周期内没有新的请求，则清理并调用最初的 onAfter。
            // Note: The onAfter here should be the initially passed onAfter, not operation.onAfter,
            // as operation.onAfter might have been updated during the limiting period.
            // However, based on the existing logic, if callback is null, it means there was no new onExecute.
            // Executing the initial onAfter might be the desired behavior, indicating a full "no new request" cycle has ended.
            // A more common rate limit pattern might only call onAfter when there's an actual execution.
            // The logic here is: if there are no new requests in a cycle, clean up and call the initial onAfter.
            onAfter?.call();
          } else {
            /// 如果有缓存的回调 (即在上一个时间窗口内有新的调用)
            /// 执行缓存的回调和对应的 onAfter 回调
            /// 然后清除缓存的回调，为下一个时间窗口做准备
            /// If there is a cached callback (i.e., there were new calls in the previous time window),
            /// execute the cached callback and its corresponding onAfter callback.
            /// Then clear the cached callbacks to prepare for the next time window.
            operation.callback?.call();
            operation.onAfter?.call(); // 执行的是被更新后的 onAfter
            // Execute the updated onAfter
            operation.callback = null;
            operation.onAfter = null;
          }
        }
      }),
    );

    /// 将新的速率限制操作存入Map
    /// Store the new rate limit operation in the Map.
    _operations[tag] = rateLimit;

    /// 立即执行首次的 onExecute 回调
    /// Immediately execute the initial onExecute callback.
    onExecute();
    return false;
  }

  /// 取消指定tag的速率限制操作
  /// [tag] 要取消的速率限制操作的标识符
  /// Cancels the rate limit operation for the specified tag.
  /// [tag] The identifier of the rate limit operation to cancel.
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// 取消所有正在进行的速率限制操作
  /// 会清理所有定时器和操作记录
  /// Cancels all ongoing rate limit operations.
  /// This will clear all timers and operation records.
  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  /// 获取当前正在进行的速率限制操作数量
  /// 返回速率限制操作Map的长度
  /// Gets the number of currently ongoing rate limit operations.
  /// Returns the length of the rate limit operations Map.
  static int get count => _operations.length;
}
