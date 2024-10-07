extension FastBoolNullSafeExtension on bool? {
  /// 默认值
  bool get nullSafeOrFalse => this ?? false;

  /// 默认值
  bool get nullSafeOrTrue => this ?? true;

  /// 可选默认值
  bool nullSafe({bool? value}) {
    return (this ?? value).nullSafeOrFalse;
  }

  /// 如果为空抛出异常
  bool nullSafeThrow({Exception? exception}) {
    if (this == null) {
      throw exception ?? ArgumentError('Value should not be null');
    }
    return this!;
  }
}
