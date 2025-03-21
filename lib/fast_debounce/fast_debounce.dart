import 'dart:async' show Timer;

/// 定义一个void回调作为参数，避免导入过多的包
/// A void callback, i.e. (){}, so we don't need to import e.g. `dart.ui`
typedef FastDebounceVoidCallback = void Function();

class _FastDebounceOperation {
  FastDebounceVoidCallback callback;
  Timer timer;
  _FastDebounceOperation(this.callback, this.timer);
}

///
class FastDebounce {
  ///不允许外部实例化
  FastDebounce._();

  static final Map<String, _FastDebounceOperation> _operations =
      <String, _FastDebounceOperation>{};

  ///
  static void debounce(
      {required String tag,
      required Duration duration,
      required FastDebounceVoidCallback onExecute}) {
    if (duration == Duration.zero) {
      ///立即执行，对于不使用
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExecute();
    } else {
      ///取消之前的
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      _operations[tag] = _FastDebounceOperation(
        onExecute,
        Timer(
          duration,
          () {
            _operations[tag]?.timer.cancel();
            _operations.remove(tag);
            onExecute();
          },
        ),
      );
    }
  }

  /// Fires the callback associated with [tag] immediately. This does not cancel the debounce timer,
  /// so if you want to invoke the callback and cancel the debounce timer, you must first call
  /// `fire(tag)` and then `cancel(tag)`.
  static void fire(String tag) {
    _operations[tag]?.callback();
  }

  ///取消发抖
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  ///取消所有发抖
  static void cancelAll() {
    _operations.forEach((key, value) {
      value.timer.cancel();
    });
    _operations.clear();
  }

  ///获取当前发抖数量
  static int get count => _operations.length;
}
