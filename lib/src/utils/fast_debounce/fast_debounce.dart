library fast_package;

import 'dart:async' show Timer;

/// 定义一个void回调作为参数，避免导入过多的包
/// A void callback, i.e. (){}, so we don't need to import e.g. `dart.ui`
/// This defines a function type with no parameters and no return value, used for the debounce callback.
typedef FastDebounceVoidCallback = void Function();

/// 防抖操作的内部实现类
/// 用于存储回调函数和定时器
/// Internal implementation class for debounce operations.
/// Used to store the callback function and the timer.
class _FastDebounceOperation {
  /// 存储需要执行的回调函数
  /// Stores the callback function to be executed.
  FastDebounceVoidCallback callback;

  /// 用于控制防抖的定时器
  /// Timer used to control the debounce.
  Timer timer;

  /// 构造函数，初始化回调函数和定时器
  /// Constructor, initializes the callback function and timer.
  _FastDebounceOperation(this.callback, this.timer);
}

/// FastDebounce 类提供了一个用于实现防抖功能的工具类
/// 防抖的主要作用是控制函数的执行频率，避免函数被频繁调用
/// The FastDebounce class provides a utility for implementing debounce functionality.
/// The main purpose of debouncing is to control the execution frequency of a function, preventing it from being called too frequently.
class FastDebounce {
  /// 私有构造函数，防止类被实例化
  /// 该类只提供静态方法，不需要创建实例
  /// Private constructor to prevent the class from being instantiated.
  /// This class only provides static methods and does not need to be instantiated.
  FastDebounce._();

  /// 用于存储所有防抖操作的Map
  /// key为标识符tag，value为对应的防抖操作
  /// A Map to store all debounce operations.
  /// The key is the identifier tag, and the value is the corresponding debounce operation.
  static final Map<String, _FastDebounceOperation> _operations =
      <String, _FastDebounceOperation>{};

  /// 核心防抖方法
  /// [tag] 用于标识特定的防抖操作
  /// [duration] 防抖延迟时间
  /// [onExecute] 需要执行的回调函数
  /// Core debounce method.
  /// [tag] Used to identify a specific debounce operation.
  /// [duration] Debounce delay time.
  /// [onExecute] The callback function to be executed.
  static void debounce(
      {required String tag,
      required Duration duration,
      required FastDebounceVoidCallback onExecute}) {
    if (duration == Duration.zero) {
      /// 当延迟时间为0时，立即执行回调
      /// 同时清理已存在的定时器和操作记录
      /// When the delay time is zero, execute the callback immediately.
      /// Also, clean up existing timers and operation records.
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExecute();
    } else {
      /// 设置防抖
      /// 1. 取消之前的定时器（如果存在）
      /// Set up debounce.
      /// 1. Cancel the previous timer (if it exists).
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);

      /// 2. 创建新的防抖操作
      /// 2. Create a new debounce operation.
      _operations[tag] = _FastDebounceOperation(
        onExecute,
        Timer(
          duration,
          () {
            /// 定时器触发时，执行回调并清理资源
            /// When the timer triggers, execute the callback and clean up resources.
            _operations[tag]?.timer.cancel();
            _operations.remove(tag);
            onExecute();
          },
        ),
      );
    }
  }

  /// 立即执行指定tag的回调函数
  /// [tag] 防抖操作的标识符
  /// 注意：这个方法不会取消定时器，如果需要同时取消定时器，
  /// 需要在调用fire后再调用cancel方法
  /// Fires the callback associated with [tag] immediately.
  /// [tag] The identifier of the debounce operation.
  /// Note: This method does not cancel the debounce timer.
  /// If you want to invoke the callback and cancel the debounce timer, you must first call
  /// `fire(tag)` and then `cancel(tag)`.
  static void fire(String tag) {
    _operations[tag]?.callback();
  }

  /// 取消指定tag的防抖操作
  /// [tag] 要取消的防抖操作的标识符
  /// Cancels the debounce operation for the specified tag.
  /// [tag] The identifier of the debounce operation to cancel.
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// 取消所有正在进行的防抖操作
  /// 会清理所有定时器和操作记录
  /// Cancels all ongoing debounce operations.
  /// This will clear all timers and operation records.
  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  /// 获取当前正在进行的防抖操作数量
  /// 返回防抖操作Map的长度
  /// Gets the number of currently ongoing debounce operations.
  /// Returns the length of the debounce operations Map.
  static int get count => _operations.length;
}
