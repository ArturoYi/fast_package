
extension FastDoubleNullSafeExtension on double? {
  /// 默认值
  double get nullSafeOrEmpty => this ?? 0.0;

  /// 可选默认值
  double nullSafe({double? value}) {
    return (this ?? value).nullSafeOrEmpty;
  }

  /// 如果为空抛出异常
  double nullSafeThrow({Exception? exception}) {
    if (this == null) {
      throw exception ?? ArgumentError('Value should not be null');
    }
    return this!;
  }
}
