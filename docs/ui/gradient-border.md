---
title: 渐变边框
---

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
