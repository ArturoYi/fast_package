# fast_package

帮助快速开发的 package，目的是基于纯 flutter 实现各种工具方法，也会记录在开发中经常使用的package。

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

## 异步任务队列 (FastAsyncQueue)

一个用于管理和按顺序执行异步任务的队列实现。

This package would be useful if you have multiple widgets in a screen or even in multiple screens that need to do some async requests that are related to each other.

### 主要特性
- 顺序执行异步任务
- 自动启动模式（添加任务后立即执行）
- 可配置的任务重试机制
- 队列状态变化的事件监听
- 任务标签和状态跟踪

### 基本使用-创建队列
```dart
// 普通队列，需要手动调用 start()
 final asyncQ = AsyncQueue();
  asyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 1), () => print("normalQ: 1")));
  asyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 4), () => print("normalQ: 2")));
  asyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 2), () => print("normalQ: 3")));
  asyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 1), () => print("normalQ: 4")));

await asyncQ.start();

    // normalQ: 1
    // normalQ: 2
    // normalQ: 3
    // normalQ: 4

```

### 自动执行队列

```dart
// 自动启动队列，添加任务后立即执行
final autoQueue = FastAsyncQueue.autoStart();
final autoAsyncQ = AsyncQueue.autoStart();

  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 1), () => print("AutoQ: 1")));
  await Future.delayed(const Duration(seconds: 6));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 0), () => print("AutoQ: 1.2")));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 0), () => print("AutoQ: 1.3")));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 4), () => print("AutoQ: 2")));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 3), () => print("AutoQ: 2.2")));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 2), () => print("AutoQ: 3")));
  autoAsyncQ.addJob(() =>
      Future.delayed(const Duration(seconds: 1), () => print("AutoQ: 4")));

    // AutoQ: 1
    // AutoQ: 1.2
    // AutoQ: 1.3
    // AutoQ: 2
    // AutoQ: 2.2
    // AutoQ: 3
    // AutoQ: 4

```

### 队列监听


```dart
  final asyncQ = AsyncQueue();

  asyncQ.addQueueListener((event) => print("$event"));
```

### 队列失败重试

```dart
    q.addJob(() async {
      try {
        //do something
      } catch (e) {
        q.retry();
      }
    },
    //default is 1
     retryTime: 3,
    );
```


