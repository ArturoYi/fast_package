---
title: Toast
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_toast" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_toast/</code>
</p>

## 概览 {#overview}

全局 Toast 挂在 App 根 Overlay 上：调用 `showToast` / `showCustomToast` **无需** `BuildContext`，与当前路由栈解耦。同一时刻只展示一条，其余 FIFO 排队。

| 要点 | 说明 |
| --- | --- |
| 展示入口 | `showToast(message)` / `showCustomToast(widget)` |
| 挂载 | `MaterialApp.builder` 包一层 `FastToastOverlay` |
| 队列 | 单槽、FIFO；pending 上限 5，满时丢掉最旧 |
| 主题 | `FastToastTheme`（`ThemeExtension`），只作用于文本面板 |
| **不做** | `success` / `error` / `info` type、高优插队、进度 Toast |

::: tip
未挂载 `FastToastOverlay` 时调用只会入队、不抛错。完整演示见 example 的 `ToastExample` 页。
:::

---

## 接入 {#setup}

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

MaterialApp(
  builder: (context, child) {
    return FastToastOverlay(
      child: child ?? const SizedBox.shrink(),
    );
  },
  // ...
);
```

---

## 基础使用 {#toast-example}

```dart
import 'package:fast_package/fast_package.dart';

showToast('保存成功');

showToast(
  '网络异常',
  config: FastToastConfig(
    duration: Duration(seconds: 3),
    position: FastToastPosition.bottom,
    dismissible: true,
  ),
);

showCustomToast(
  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: Colors.green),
      SizedBox(width: 8),
      Text('自定义内容'),
    ],
  ),
);

FastToast.dismiss();
FastToast.dismissAll();
```

`showCustomToast` 的 Widget 作为 Toast **内容**插入 Overlay：宿主仍负责队列、位置、时长与动画，**不会**再套默认背景和内边距。内容构建在 Overlay 子树中，可用 `Builder` / `Theme.of`；不要捕获已销毁的页面 `BuildContext`。

---

## 注册主题 {#toast-theme-setup}

`FastToastTheme` 只影响 `showToast` 的默认文本面板：

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [FastToastTheme.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [FastToastTheme.dark],
  ),
  builder: (context, child) {
    return FastToastOverlay(child: child ?? const SizedBox.shrink());
  },
);
```

解析优先级：

1. `ThemeData` 上的 `FastToastTheme` 扩展
2. 按 `ThemeData.brightness` 回退到 `FastToastTheme.light` / `dark`

---

## API {#toast-api}

### `showToast` / `showCustomToast`

```dart
void showToast(String message, {FastToastConfig? config});

void showCustomToast(Widget toast, {FastToastConfig? config});
```

### `FastToast`

| 成员 | 说明 |
| --- | --- |
| `isShowing` | 当前是否正在展示 |
| `pendingCount` | 待展示条数（不含当前条） |
| `dismiss()` | 当前条退场后播放下一条；空闲时为空操作 |
| `dismissAll()` | 清队列并立即移除当前条 |

### `FastToastConfig`

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `duration` | `2000ms` | 退场前停留时长 |
| `position` | `FastToastPosition.center` | `top` / `center` / `bottom` |
| `dismissible` | `false` | 点击内容关闭 |

---

## 非目标 {#non-goals}

- 没有 `FastToastType`，也没有 `success` / `error` / `info` 便捷方法
- 不与 Loading 协作、不做高优先级插队
- 不提供可切换的动画枚举或进度 Toast
