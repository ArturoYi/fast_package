---
title: Debounce, Throttle, and Rate Limit
---

### Debounce, Throttle, and Rate Limit

#### 1. Debounce

Prevents a function from firing repeatedly in a short window—only the last call runs.

```dart
import 'package:fast_package/fast_package.dart';

FastDebounce.debounce(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Debounce interval
  onExecute: () {  // Callback to run
    setState(() {
      count--;
    });
  },          
);
```

#### 2. Throttle

Limits a function to at most one execution within a given time window.

```dart
import 'package:fast_package/fast_package.dart';

FastThrottle.throttle(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Throttle interval
  onExecute: () {  // Callback to run
    setState(() {
      count--;
    });
  },
);
```

#### 3. Rate limit

Controls how often a function may run so executions stay on a fixed interval.

```dart
import 'package:fast_package/fast_package.dart';

FastRateLimit.rateLimit(
  tag: 'removeCount',  // Unique identifier
  duration: const Duration(seconds: 1), // Rate-limit interval
  onExecute: () {  // Callback to run
    setState(() {
      count--;
    });
  },
);
```
