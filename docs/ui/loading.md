---
title: Loading
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_loading" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_loading/</code>
</p>

<DocCredit module="loading" />

## 概览 {#overview}

全局 Loading 挂在 App 根 Overlay 上：调用 `showLoading` **无需** `BuildContext`，与当前路由栈解耦。始终居中，同一时刻只展示一条；再次调用会**立即替换**当前条，不排队。

| 要点 | 说明 |
| --- | --- |
| 展示入口 | `showLoading()`；自定义内容传 `builder` |
| 挂载 | `MaterialApp.builder` 包一层 `FastLoadingOverlay` |
| 位置 | 仅居中 |
| 关闭 | 必须调用 `FastLoading.dismiss()`（或点遮罩，若开启） |
| 返回 | 展示期间默认禁止返回；路由级拦截需传入同一把 `navigatorKey` |
| 主题 | `FastLoadingTheme`（`ThemeExtension`），作用于默认面板与遮罩 |
| **不做** | 多位置、FIFO 队列、自动消失、进度百分比 |

::: tip
未挂载 `FastLoadingOverlay` 时调用只会记下 pending、不抛错。完整演示见 example 的 `LoadingExample` 页。
:::

---

## 接入 {#setup}

与 Toast 一起用时，把 Loading 包在外侧，这样遮罩会盖在 Toast 之上：

```dart
import 'package:flutter/material.dart';
import 'package:fast_package/fast_package.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

MaterialApp(
  navigatorKey: rootNavigatorKey,
  builder: (context, child) {
    return FastLoadingOverlay(
      navigatorKey: rootNavigatorKey,
      child: FastToastOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  },
  // ...
);
```

只使用 Loading 时，包一层 `FastLoadingOverlay` 即可。`navigatorKey` 必须和 `MaterialApp.navigatorKey` **同一把**：系统返回、AppBar 返回、iOS 侧滑、`Navigator.maybePop` 都会走这把 key 上的当前路由。不传 key 时拦不住已压栈页面的返回。直接调用 `Navigator.pop` **不会**被拦住。

---

## 基础使用 {#loading-example}

```dart
import 'package:fast_package/fast_package.dart';

showLoading();

showLoading(message: '加载中...');

showLoading(
  message: '点遮罩关闭',
  config: FastLoadingConfig(barrierDismissible: true),
);

showLoading(
  builder: (context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 12),
        Text('自定义内容'),
      ],
    );
  },
);

FastLoading.dismiss();
FastLoading.dismissNow();
```

`builder` 返回的 Widget 作为 Loading **内容**插入 Overlay：宿主仍负责居中、淡入淡出与遮罩，**不会**再套默认背景和转圈。回调拿到的是 Overlay 子树的 `BuildContext`，可直接 `Theme.of`；不要捕获已销毁的页面 `BuildContext`。传入 `builder` 时会忽略 `message`。

---

## 注册主题 {#loading-theme-setup}

`FastLoadingTheme` 影响默认面板（背景、转圈色、文案、投影）以及遮罩颜色：

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [FastLoadingTheme.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [FastLoadingTheme.dark],
  ),
  builder: (context, child) {
    return FastLoadingOverlay(child: child ?? const SizedBox.shrink());
  },
);
```

解析优先级：

1. `ThemeData` 上的 `FastLoadingTheme` 扩展
2. 按 `ThemeData.brightness` 回退到 `FastLoadingTheme.light` / `dark`

---

## API {#loading-api}

### `showLoading`

```dart
void showLoading({
  String? message,
  WidgetBuilder? builder,
  FastLoadingConfig? config,
});
```

### `FastLoading`

| 成员 | 说明 |
| --- | --- |
| `isShowing` | 当前是否正在展示 |
| `dismiss()` | 当前条退场动画后关闭；空闲时清空 pending |
| `dismissNow()` | 立即移除当前条并丢掉 pending |

### `FastLoadingConfig`

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `barrierDismissible` | `false` | 点击遮罩关闭 |
| `lockPop` | `true` | 展示期间禁止返回 |

---

## 非目标 {#non-goals}

- 没有 top / bottom 等位置，也不跟键盘做复杂合成层平移
- 没有队列、没有自动关闭时长
- 不与 Toast 协作、不做进度条 / 百分比 Loading
