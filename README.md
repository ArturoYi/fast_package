# fast_package

帮助快速开发的 package，目的是基于纯 flutter 实现各种 util 合集。
一切 util 都基于业务。

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

//不断调用，会每隔1s执行一次
```
