---
title: Debounce, Throttle, Rate Limit
---

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
