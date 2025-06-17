import 'dart:math';

extension FastNumExtension on num {
  /// 判断数字是否在指定范围内（包含边界值）
  /// 
  /// 示例：
  /// ```dart
  /// 5.isBetween(1, 10) // true
  /// 1.isBetween(1, 10) // true
  /// 10.isBetween(1, 10) // true
  /// 0.isBetween(1, 10) // false
  /// 11.isBetween(1, 10) // false
  /// ```
  bool isBetween(num betweenOne, num betweenTwo) {
    return this >= min(betweenOne, betweenTwo) && this <= max(betweenOne, betweenTwo);
  }

  /// 判断数字是否能被指定的数整除
  /// 
  /// 示例：
  /// ```dart
  /// 10.isDivisibleBy(2) // true
  /// 10.isDivisibleBy(3) // false
  /// 10.isDivisibleBy(0) // false，除数不能为0
  /// ```
  bool isDivisibleBy(num divisor) {
    if (divisor == 0) return false;
    return this % divisor == 0;
  }
}

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
