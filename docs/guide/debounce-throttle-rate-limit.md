---
title: 防抖、节流、速率限制
---

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
