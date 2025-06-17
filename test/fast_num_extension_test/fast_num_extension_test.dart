import 'package:flutter_test/flutter_test.dart';
import 'package:fast_package/fast_package.dart';

void main() {
  group("测试数字扩展", () {
    test(
        '测试数字区间判断\n'
        'Test number range check', () {
      expect(5.isBetween(1, 10), true);
      expect(5.isBetween(10, 1), true);
      expect(5.isBetween(5, 10), true);
      expect(5.isBetween(1, 4), false);
      expect(5.isBetween(6, 10), false);

      // 测试浮点数
      expect(5.5.isBetween(1, 10), true);
      expect(5.5.isBetween(5.5, 10), true);
      expect(5.5.isBetween(1, 5.4), false);
    });

    group("测试数字空安全扩展", () {
      test(
          '测试默认值\n'
          'Test default value', () {
        num? nullValue;
        expect(nullValue.nullSafeOrEmpty, 0);
        expect(10.nullSafeOrEmpty, 10);
      });

      test(
          '测试可选默认值\n'
          'Test optional default value', () {
        num? nullValue;
        expect(nullValue.nullSafe(), 0);
        expect(nullValue.nullSafe(value: 5), 5);
        expect(10.nullSafe(), 10);
        expect(10.nullSafe(value: 5), 10);
      });

      test(
          '测试空值抛出异常\n'
          'Test null value throws exception', () {
        num? nullValue;
        expect(
          () => nullValue.nullSafeThrow(),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => nullValue.nullSafeThrow(exception: Exception('Custom error')),
          throwsA(isA<Exception>()),
        );
        expect(10.nullSafeThrow(), 10);
      });
    });

    test(
        '测试整除判断\n'
        'Test divisibility check', () {
      expect(10.isDivisibleBy(2), true);
      expect(10.isDivisibleBy(3), false);
      expect(10.isDivisibleBy(5), true);
      expect(10.isDivisibleBy(10), true);

      // 测试0作为除数
      expect(10.isDivisibleBy(0), false);

      // 测试负数
      expect(10.isDivisibleBy(-2), true);
      expect((-10).isDivisibleBy(2), true);
      expect((-10).isDivisibleBy(-2), true);

      // 测试浮点数
      expect(10.0.isDivisibleBy(2), true);
      expect(10.isDivisibleBy(2.0), true);
      expect(10.5.isDivisibleBy(2), false);
    });
  });
}
