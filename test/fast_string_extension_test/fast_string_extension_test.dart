import 'package:flutter_test/flutter_test.dart';
import 'package:fast_package/fast_package.dart';

void main() {
  group("测试字符串空安全扩展", () {
    test(
        '字符串空安全扩展测试：测试null值处理、默认值设置和异常抛出\n'
        'String null security extension test: test null value handling, default value setting and exception throwing',
        () {
      String? strNullSafe;
      expect(strNullSafe, null);
      expect(strNullSafe.nullSafe(value: 'abc'), 'abc');
      expect(strNullSafe.nullSafeOrEmpty, '');
      expect(() => strNullSafe.nullSafeThrow(), throwsA(isA<ArgumentError>()));
      expect(() => strNullSafe.nullSafeThrow(exception: Exception()),
          throwsException);
    });
  });

  group("测试字符串命名格式转换", () {
    test(
        '测试各种命名格式转换：驼峰、帕斯卡、蛇形命名等\n'
        'Test various naming format conversions: camel case, pascal case, snake case, etc.',
        () {
      String str = 'hello_world_example';
      expect(str.toCamelCase, 'helloWorldExample');
      expect(str.toPascalCase, 'HelloWorldExample');
      expect(str.toSnakeCase, 'HELLO_WORLD_EXAMPLE');
      expect(str.toSnakeCaseLower, 'hello_world_example');
      expect(str.toKebabCase, 'hello-world-example');
    });
  });

  group("测试URL验证", () {
    test(
        '测试URL有效性验证\n'
        'Test URL validation', () {
      // 有效的URL
      expect('https://www.example.com'.isValidUrl, true);
      expect('http://example.com/path'.isValidUrl, true);
      expect('www.example.com'.isValidUrl, true);

      // 无效的URL
      expect('not-a-url'.isValidUrl, false);
      expect('http://'.isValidUrl, false);
      expect('https://'.isValidUrl, false);
    });
  });


}
