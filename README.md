# fast_package

帮助快速开发的 package，目的是基于纯 flutter 实现各种工具方法。

一切基于业务。

如果你有更好的主意，可以联系我。

## 使用

请在安装前检查最新版本。如果新版本有任何问题，请使用以前的版本

```dart
dependencies:
  flutter:
    sdk: flutter
  # add fast_package
  fast_package: ^{latest version}
```

## Add the following imports to your Dart code

```dart
import 'package:fast_package/fast_package.dart';
```

# 节流、防抖、速率限制

1. 防抖使用：

- 不断调用，会在1s后执行一次

```dart
import 'package:fast_package/fast_package.dart';

FastDebounce.debounce(
     tag: 'removeCount',  // <-------- 唯一标识
     duration: const Duration(seconds: 1), //<-------- 防抖时间
     onExecute: () {  // <-------- 执行函数
       setState(() {
          count--;
        });
      },          
);
```

2.  节流使用：

- 不断调用，会每隔1s一定执行一次

```dart
import 'package:fast_package/fast_package.dart';

FastThrottle.throttle(
     tag:'removeCount',  // <-------- 唯一标识
     duration: const Duration(seconds: 1), //<-------- 节流时间
     onExecute: () {  // <-------- 执行函数
       setState(() {
          count--;
        });
      },
);
```
3. 速率限制使用：

- 不断调用，会每隔1s执行一次

```dart
import 'package:fast_package/fast_package.dart';
FastRateLimit.rateLimit(
  tag: 'removeCount',  // <-------- 唯一标识
  duration: const Duration(seconds: 1), //<-------- 速率限制时间
  onExecute: () {  // <-------- 执行函数
    setState(() {
      count--;
    });
  },
);
```

## 扩展

比较多，有特点需要时再决定是否查看，没必要全部阅读。

### 空安全扩展（string,double,int,bool,num）

```dart
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default"));//default
print(str.nullSafeThrow()); // Value should not be null

```

## 字符串扩展

```dart
 /// 将字符串转换为小驼峰命名（to lower camel case）
  /// Convert the string into a small camel case.
  String get toCamelCase => _convertToCamelCase(this, false);
  // 示例：
  // "hello_world" => "helloWorld"
  // "user-name" => "userName"
  // "FirstName" => "firstName"

  ///  将字符串转换为帕斯卡命名法：大驼峰命名 (to PascalCase)
  ///  Convert strings into Pascal nomenclature: big hump naming
  String get toPascalCase => _convertToCamelCase(this, true);
  // 示例：
  // "hello_world" => "HelloWorld"
  // "user-name" => "UserName"
  // "firstName" => "FirstName"

  /// 将字符串转换为大蛇形命名法（Snake Case）
  /// Convert a string into a Big Snake Case.
  String get toSnakeCase => _toDelimiterNaming(this, '_').toUpperCase();
  // 示例：
  // "helloWorld" => "HELLO_WORLD"
  // "user-name" => "USER_NAME"
  // "FirstName" => "FIRST_NAME"

  /// 将字符串转换为小蛇形命名法（Small Snake Case）
  /// Convert a string into a Big Snake Case.
  String get toSnakeCaseLower => _toDelimiterNaming(this, '_').toLowerCase();
  // 示例：
  // "helloWorld" => "hello_world"
  // "user-name" => "user_name"
  // "FirstName" => "first_name"

  /// 将字符串转换为字符串命名
  /// Convert a string to a string name
  String get toKebabCase => _toDelimiterNaming(this, '-').toLowerCase();
  // 示例：
  // "helloWorld" => "hello-world"
  // "user_name" => "user-name"
  // "FirstName" => "first-name"
```