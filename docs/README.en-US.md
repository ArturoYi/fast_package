<div align="center">

- [中文](README.zh-CN.md) | **English**

</div>

# Fast Package

[![pub package](https://img.shields.io/pub/v/fast_package.svg)](https://pub.dev/packages/fast_package)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A fast development toolkit based on pure Flutter, providing common utility methods, extension functions, and UI components.

## 📋 Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
  - [Debounce, Throttle, Rate Limit](#debounce-throttle-rate-limit)
  - [Async Task Queue](#async-task-queue)
  - [String Extensions](#string-extensions)
  - [Null Safety Extensions](#null-safety-extensions)
  - [Number Extensions](#number-extensions)
  - [Size Calculation Tools](#size-calculation-tools)
- [UI Components](#ui-components)
  - [Gradient Borders](#gradient-borders)
  - [Cover Box](#cover-box)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Features

- **🔄 Async Control**: Debounce, throttle, and rate limit functionality
- **📋 Task Queue**: Sequential execution of asynchronous task queue management
- **🔧 Extension Functions**: Rich string, number, and null safety extensions
- **📐 Size Tools**: Intelligent size calculation and adaptation tools
- **🎨 UI Components**: Practical UI components and decorators
- **⚡ High Performance**: Pure Flutter implementation with no additional dependencies
- **🛡️ Type Safety**: Complete null safety support

## 🏃‍♂️ Quick Start

### Installation

Please check the latest version before installation. If there are any issues with the new version, please use the previous version.

```yaml
dependencies:
  flutter:
    sdk: flutter
  # add fast_package
  fast_package: ^{latest version}
```

### Import

```dart
import 'package:fast_package/fast_package.dart';
```

## 🔧 Core Features

### Debounce, Throttle, Rate Limit

#### 1. Debounce

Prevents a function from being called multiple times in a short period, only executes the last call.

```dart
import 'package:fast_package/fast_package.dart';

FastDebounce.debounce(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Debounce duration
  onExecute: () {  // Execute function
    setState(() {
      count--;
    });
  },          
);
```

#### 2. Throttle

Limits a function to execute only once within a certain time period.

```dart
import 'package:fast_package/fast_package.dart';

FastThrottle.throttle(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Throttle duration
  onExecute: () {  // Execute function
    setState(() {
      count--;
    });
  },
);
```

#### 3. Rate Limit

Controls the frequency of function execution, ensuring execution at specified intervals.

```dart
import 'package:fast_package/fast_package.dart';

FastRateLimit.rateLimit(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Rate limit duration
  onExecute: () {  // Execute function
    setState(() {
      count--;
    });
  },
);
```

### Async Task Queue

A queue implementation for managing and executing asynchronous tasks in sequence.

#### Key Features

- ✅ Sequential execution of async tasks
- ✅ Auto-start mode
- ✅ Configurable task retry mechanism
- ✅ Event listening for queue state changes
- ✅ Task labeling and status tracking

#### Basic Usage - Create Queue

```dart
// Normal queue, requires manual start() call
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

#### Auto-Execute Queue

```dart
// Auto-start queue, executes immediately after adding tasks
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

#### Queue Monitoring

```dart
final asyncQ = AsyncQueue();
asyncQ.addQueueListener((event) => print("$event"));
```

#### Queue Failure Retry

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

### String Extensions

Provides rich string conversion and formatting functionality.

```dart
// Convert the string into a small camel case
String get toCamelCase;
// Examples:
// "hello_world" => "helloWorld"
// "user-name" => "userName"
// "FirstName" => "firstName"

// Convert strings into Pascal nomenclature: big hump naming
String get toPascalCase;
// Examples:
// "hello_world" => "HelloWorld"
// "user-name" => "UserName"
// "firstName" => "FirstName"

// Convert a string into a Big Snake Case
String get toSnakeCase;
// Examples:
// "helloWorld" => "HELLO_WORLD"
// "user-name" => "USER_NAME"
// "FirstName" => "FIRST_NAME"

// Convert a string into a Small Snake Case
String get toSnakeCaseLower;
// Examples:
// "helloWorld" => "hello_world"
// "user-name" => "user_name"
// "FirstName" => "first_name"

// Convert a string to a kebab case
String get toKebabCase;
// Examples:
// "helloWorld" => "hello-world"
// "user_name" => "user-name"
// "FirstName" => "first-name"
```

### Null Safety Extensions

Provides safe null value handling extensions for various data types.

```dart
// String null safety extensions
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default")); // "default"
print(str.nullSafeThrow()); // Throws: Value should not be null

// Number null safety extensions
int? num = null;
print(num.nullSafeOrZero); // 0
print(num.nullSafe(42)); // 42

// Boolean null safety extensions
bool? flag = null;
print(flag.nullSafeOrFalse); // false
print(flag.nullSafe(true)); // true
```

### Number Extensions

Provides number formatting and conversion functionality.

```dart
// Number formatting
double price = 1234.5678;
print(price.toCurrency()); // "¥1,234.57"
print(price.toPercent()); // "123,456.78%"

// Number conversion
int count = 1000;
print(count.toFileSize()); // "1.0 KB"
print(count.toDuration()); // "16 minutes 40 seconds"
```

### Size Calculation Tools

Provides intelligent size calculation and adaptation tools.

```dart
import 'package:fast_package/fast_package.dart';

// Calculate cover scan size
Size parentSize = Size(100, 100);
Size childSize = Size(50, 80);
Size result = fastCoverScanSize(parentSize, childSize);
// Result: Size(100, 160) - scaled proportionally by width
```

## 🎨 UI Components

### Gradient Borders

Add gradient border effects to containers.

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

### Cover Box

Smart container component that automatically handles content coverage and adaptation.

```dart
import 'package:fast_package/fast_package.dart';

CoverBox(
  width: 200,
  height: 200,
  child: Image.network('your_image_url'),
)
```

## 🤝 Contributing

We welcome all forms of contributions! If you have better ideas or find issues, please:

1. 🐛 Report bugs
2. 💡 Suggest new features
3. 📝 Improve documentation
4. 🔧 Submit code

If you have better ideas, please let me know.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 