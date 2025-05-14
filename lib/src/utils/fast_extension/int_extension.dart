
extension FastIntNullSafeExtension on int? {
  /// 默认值
  int get nullSafeOrEmpty => this ?? 0;

  /// 可选默认值
  int nullSafe({int? value}) {
    return (this ?? value).nullSafeOrEmpty;
  }

  /// 如果为空抛出异常
  int nullSafeThrow({Exception? exception}) {
    if (this == null) {
      throw exception ?? ArgumentError('Value should not be null');
    }
    return this!;
  }
}
