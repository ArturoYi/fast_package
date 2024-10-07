extension FastNumNullSafeExtension on num? {
  /// 默认值
  num get nullSafeOrEmpty => this ?? 0;

  /// 可选默认值
  num nullSafe({num? value}) {
    return (this ?? value).nullSafeOrEmpty;
  }

  /// 如果为空抛出异常
  num nullSafeThrow({Exception? exception}) {
    if (this == null) {
      throw exception ?? ArgumentError('Value should not be null');
    }
    return this!;
  }
}
