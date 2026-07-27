---
title: Gradient Borders
---

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
