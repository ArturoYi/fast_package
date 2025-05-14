import 'package:flutter_test/flutter_test.dart';
import 'package:fast_package/fast_package.dart';
void main() {
  group("test fast_object_extension", () {
    test(
        '字符串空安全扩展,在遇到null时返回空值或者给予默认值或者异常 \n String null security extension, which returns null value or gives default value or exception when null is encountered.',
        () {
      String? strNullSafe;
      expect(strNullSafe, null);
      expect(strNullSafe.nullSafe(value: 'abc'), 'abc');
      expect(strNullSafe.nullSafeOrEmpty, '');
      expect(() => strNullSafe.nullSafeThrow(), throwsA(isA<ArgumentError>()));
      expect(() => strNullSafe.nullSafeThrow(exception: Exception()),
          throwsException);
    });

    test(
        '字符串命名格式转换，大驼峰，小驼峰，大蛇形，小蛇形 \n String naming format conversion, big hump, small hump, big snake, small snake',
        () {
      String str = 'hello_world_example';
      expect(str.toCamelCase, 'helloWorldExample');
      expect(str.toPascalCase, 'HelloWorldExample');
      expect(str.toSnakeCase, 'HELLO_WORLD_EXAMPLE');
      expect(str.toSnakeCaseLower, 'hello_world_example');
      expect(str.toKebabCase, 'hello-world-example');
    });
  });
}
