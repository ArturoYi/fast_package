<div align="center">

- **中文** | [English](README.en-US.md)

</div>

# Fast Package

[![pub package](https://img.shields.io/pub/v/fast_package.svg)](https://pub.dev/packages/fast_package)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

一个基于纯 Flutter 实现的快速开发工具包，提供常用的工具方法、扩展函数和 UI 组件。

## 📋 目录

- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [核心功能](#核心功能)
  - [防抖、节流、速率限制](#防抖节流速率限制)
  - [异步任务队列](#异步任务队列)
  - [字符串扩展](#字符串扩展)
  - [空安全扩展](#空安全扩展)
  - [数字扩展](#数字扩展)
  - [尺寸计算工具](#尺寸计算工具)
- [UI 组件](#ui-组件)
  - [渐变边框](#渐变边框)
  - [覆盖容器](#覆盖容器)
- [贡献](#贡献)
- [许可证](#许可证)

## 🚀 功能特性

- **🔄 异步控制**: 防抖、节流、速率限制功能
- **📋 任务队列**: 顺序执行异步任务的队列管理
- **🔧 扩展函数**: 丰富的字符串、数字、空安全扩展
- **📐 尺寸工具**: 智能的尺寸计算和适配工具
- **🎨 UI 组件**: 实用的 UI 组件和装饰器
- **⚡ 高性能**: 基于纯 Flutter 实现，无额外依赖
- **🛡️ 类型安全**: 完整的空安全支持

## 🏃‍♂️ 快速开始

### 安装

请在安装前检查最新版本。如果新版本有任何问题，请使用以前的版本。

```yaml
dependencies:
  flutter:
    sdk: flutter
  # add fast_package
  fast_package: ^{latest version}
```

### 导入

```dart
import 'package:fast_package/fast_package.dart';
```

## 🔧 核心功能

### 防抖、节流、速率限制

#### 1. 防抖 (Debounce)

防止函数在短时间内被多次调用，只执行最后一次调用。

```dart
import 'package:fast_package/fast_package.dart';

FastDebounce.debounce(
  tag: 'removeCount',  // 唯一标识
  duration: const Duration(seconds: 1), // 防抖时间
  onExecute: () {  // 执行函数
    setState(() {
      count--;
    });
  },          
);
```

#### 2. 节流 (Throttle)

限制函数在一定时间内只能执行一次。

```dart
import 'package:fast_package/fast_package.dart';

FastThrottle.throttle(
  tag: 'removeCount',  // 唯一标识
  duration: const Duration(seconds: 1), // 节流时间
  onExecute: () {  // 执行函数
    setState(() {
      count--;
    });
  },
);
```

#### 3. 速率限制 (Rate Limit)

控制函数执行的频率，确保按指定间隔执行。

```dart
import 'package:fast_package/fast_package.dart';

FastRateLimit.rateLimit(
  tag: 'removeCount',  // 唯一标识
  duration: const Duration(seconds: 1), // 速率限制时间
  onExecute: () {  // 执行函数
    setState(() {
      count--;
    });
  },
);
```

### 异步任务队列

一个用于管理和按顺序执行异步任务的队列实现。

#### 主要特性

- ✅ 顺序执行异步任务
- ✅ 自动启动模式
- ✅ 可配置的任务重试机制
- ✅ 队列状态变化的事件监听
- ✅ 任务标签和状态跟踪

#### 基本使用 - 创建队列

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

// Output:
// normalQ: 1
// normalQ: 2
// normalQ: 3
// normalQ: 4
```

#### 自动执行队列

```dart
// 自动启动队列，添加任务后立即执行
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

// Output:
// AutoQ: 1
// AutoQ: 1.2
// AutoQ: 1.3
// AutoQ: 2
```

#### 队列监听

```dart
final asyncQ = AsyncQueue();
asyncQ.addQueueListener((event) => print("$event"));
```

#### 队列失败重试

```dart
q.addJob(() async {
  try {
    // do something
  } catch (e) {
    q.retry();
  }
},
// default is 1
retryTime: 3,
);
```

### 字符串扩展

提供丰富的字符串转换和格式化功能。

```dart
// 将字符串转换为小驼峰命名（to lower camel case）
String get toCamelCase;
// 示例:
// "hello_world" => "helloWorld"
// "user-name" => "userName"
// "FirstName" => "firstName"

// 将字符串转换为帕斯卡命名法：大驼峰命名 (to PascalCase)
String get toPascalCase;
// 示例:
// "hello_world" => "HelloWorld"
// "user-name" => "UserName"
// "firstName" => "FirstName"

// 将字符串转换为大蛇形命名法（Snake Case）
String get toSnakeCase;
// 示例:
// "helloWorld" => "HELLO_WORLD"
// "user-name" => "USER_NAME"
// "FirstName" => "FIRST_NAME"

// 将字符串转换为小蛇形命名法（Small Snake Case）
String get toSnakeCaseLower;
// 示例:
// "helloWorld" => "hello_world"
// "user-name" => "user_name"
// "FirstName" => "first_name"

// 将字符串转换为短横线命名法（Kebab Case）
String get toKebabCase;
// 示例:
// "helloWorld" => "hello-world"
// "user_name" => "user-name"
// "FirstName" => "first-name"
```

### 空安全扩展

为各种数据类型提供安全的空值处理扩展。

```dart
// 字符串空安全扩展
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default")); // "default"
print(str.nullSafeThrow()); // Throws: Value should not be null

// 数字空安全扩展
int? num = null;
print(num.nullSafeOrZero); // 0
print(num.nullSafe(42)); // 42

// 布尔值空安全扩展
bool? flag = null;
print(flag.nullSafeOrFalse); // false
print(flag.nullSafe(true)); // true
```

### 数字扩展

提供数字格式化和转换功能。

```dart
// 数字格式化
double price = 1234.5678;
print(price.toCurrency()); // "¥1,234.57"
print(price.toPercent()); // "123,456.78%"

// 数字转换
int count = 1000;
print(count.toFileSize()); // "1.0 KB"
print(count.toDuration()); // "16 minutes 40 seconds"
```

### 尺寸计算工具

提供智能的尺寸计算和适配工具。

```dart
import 'package:fast_package/fast_package.dart';

// 计算覆盖扫描尺寸
Size parentSize = Size(100, 100);
Size childSize = Size(50, 80);
Size result = fastCoverScanSize(parentSize, childSize);
// 结果: Size(100, 160) - 按宽度等比例拉伸
```

## 🎨 UI 组件

### 渐变边框

为容器添加渐变边框效果。

```dart
import 'package:fast_package/fast_package.dart';

Container(
  child: GradientBoxBorders(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    borderWidth: 2.0,
    child: YourWidget(),
  ),
)
```

### 覆盖容器

智能的容器组件，自动处理内容覆盖和适配。

```dart
import 'package:fast_package/fast_package.dart';

CoverBox(
  width: 200,
  height: 200,
  child: Image.network('your_image_url'),
)
```

## 🤝 贡献

我们欢迎所有形式的贡献！如果你有更好的主意或发现了问题，请：

1. 🐛 报告 Bug
2. 💡 提出新功能建议
3. 📝 改进文档
4. 🔧 提交代码

如果你有更好的主意，请告诉我。

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。 