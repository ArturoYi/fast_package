---
title: Slidable 滑动操作
outline: [2, 3]
---

<p class="doc-source">
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/ui_kit/fast_slidable" target="_blank" rel="noreferrer">GitHub 源码</a>
  <span aria-hidden="true">·</span>
  <code>lib/src/ui_kit/fast_slidable/</code>
</p>

<DocCredit module="slidable" />

## 概览 {#overview}

`FastSlidable` 给列表项做左右 / 上下滑动，露出操作按钮；可继续滑到底触发主操作并删除整行。控制器可程序化打开 / 关闭。与竖直 `FastRefresh` / `FastPagingList` 组合时，下拉或刷新处理中会锁住滑动。

| 要点 | 说明 |
| --- | --- |
| 主入口 | `FastSlidable(startPane, endPane, child)` |
| 操作区 | `FastSlidablePane` + `FastSlidableAction` |
| 动画 | `FastSlidableMotion.behind / drawer / scroll` |
| 删除 | `FastSlidableDismiss`；滑到底用 `FastSlidableFullSwipe` |
| 组互斥 | `FastSlidableGroup` + `groupTag` |
| 主题 | `FastSlidableTheme`（`ThemeExtension`） |
| **不做** | 旧通知迁移层、从 child 推断按钮、水平 Refresh 与水平 Slidable 同一方向共存、写进 `FastPagingList` 的 API |

::: tip
配置了 `dismiss` 或会删除的 `fullSwipe` 时，必须给 `FastSlidable` 设 `key`。完整演示见 example 的 `SlidableExample` 页。
:::

---

## 基础使用 {#basic}

```dart
import 'package:fast_package/fast_package.dart';

FastSlidableGroup(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return FastSlidable(
        key: ValueKey(item.id),
        groupTag: 'inbox',
        startPane: FastSlidablePane(
          motion: FastSlidableMotion.scroll,
          children: [
            FastSlidableAction(
              onPressed: (_) => share(item),
              backgroundColor: Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: '分享',
            ),
          ],
        ),
        endPane: FastSlidablePane(
          motion: FastSlidableMotion.drawer,
          dismiss: FastSlidableDismiss(onDismissed: () => remove(item)),
          fullSwipe: FastSlidableFullSwipe(threshold: 0.55),
          children: [
            FastSlidableAction(
              onPressed: (_) => archive(item),
              backgroundColor: Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: '归档',
            ),
            FastSlidableAction(
              onPressed: (_) => remove(item),
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '删除',
            ),
          ],
        ),
        child: ListTile(title: Text(item.title)),
      );
    },
  ),
)
```

`startPane` 在 LTR 下是左侧（竖直时为上），`endPane` 是右侧（竖直时为下）。`useTextDirection: true` 时 RTL 会自动对调。

---

## Motion {#motion}

`FastSlidablePane.motion`：

| 值 | 效果 |
| --- | --- |
| `behind` | 按钮像在 item 后面 |
| `drawer` | 抽屉式依次滑出 |
| `scroll` | 按钮跟着 item 移动（默认） |

进阶可传 `motionBuilder` 完全自定义。

---

## 滑到底与删除 {#dismiss}

两段阈值：

1. 松手在 `extentRatio` 内：按 `openThreshold` / `closeThreshold` 决定展开或收回
2. 拖过 `fullSwipe.threshold`：主操作铺满整行；松手触发该操作。`dismiss: true` 时再缩行

只想「滑够远就删」、不要滑到底后主操作铺满时，只设 `FastSlidableDismiss`。

主操作默认：起始侧第一个、末侧最后一个；可用 `fullSwipe.primaryIndex` 覆盖。

---

## 控制器 {#controller}

```dart
class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final FastSlidableController controller = FastSlidableController(this);

  @override
  void dispose() {
    controller.dispose(); // 只有自己 new 的实例才 dispose
    super.dispose();
  }

  void _handleOpen() {
    controller.openEnd();
    // 或 controller.openStart();
  }

  void _handleClose() {
    controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return FastSlidable(
      controller: controller,
      endPane: FastSlidablePane(...),
      child: tile,
    );
  }
}
```

外部传入的 controller 由调用方 `dispose`；组件在更换或卸载时只卸 listener，不会 dispose 外部实例。未传入时组件自建自毁。子树内可用 `FastSlidable.of(context)`。

---

## 与 FastRefresh {#refresh}

推荐：竖直 `FastRefresh` / `FastPagingList` + 水平 `FastSlidable`。

- Slidable 只注册自己那根轴的拖动手势
- 列表滚动时 `closeOnScroll`（默认 true）会关闭已打开的行
- `userOffsetNotifier == true` 或 Header / Footer 不是 `inactive` 时锁住滑动并关闭当前行
- **同一方向不做**：水平 Refresh + 水平 Slidable 不保证手势仲裁

不要把 Slidable 写进 `FastPagingList` 的 API，在 `itemBuilder` 里组合即可。

---

## 主题 {#theme}

```dart
ThemeData(
  extensions: [FastSlidableTheme.light],
)
```

解析顺序：`resolve` 入参覆盖 → `ThemeExtension` → 按亮度回退 `light` / `dark`。主题管默认时长、曲线、按钮间距 / 圆角 / 前景色回退。
