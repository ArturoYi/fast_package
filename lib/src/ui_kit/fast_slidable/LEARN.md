# FastSlidable 实现学习指南

给自己读的笔记，不进对外文档站。用法演示见 `example/lib/pages/slidable_example/` 和 `docs/ui/slidable.md`。

设计 Space（做 / 不做、相对 flutter_slidable 的取舍）见同目录 [`SPACE.md`](SPACE.md)。openspec 入口：`openspec/changes/add-fast-slidable/design.md`。**以当前 `lib` 代码为准。**

核心不是「画一排删除按钮」，而是：**用带符号的 `ratio`（`-1 ~ 1`）驱动位移，操作区只负责阈值、满滑和删除。**

## 总图

一次左滑露出按钮大致是这条链路：

```
手指拖动
  → _FastSlidableGesture        （只注册自己那根轴）
  → controller.ratio
  → paneType / direction
  → Stack + clip + SlideTransition
  → 松手 endGesture
  → FastSlidablePane（打开 / 关闭 / 满滑 / 删除）
```

对应文件分工：

| 层 | 文件 | 职责 |
| --- | --- | --- |
| 组装 | `widgets/fast_slidable_widget.dart` | 手势、裁剪、Scope、KeepAlive |
| 控制 | `controller/fast_slidable_controller.dart` | `ratio`、打开 / 关闭 / 删除 |
| 所有权 | `widgets/fast_slidable_widget.dart` | 外部实例调用方 dispose；自建实例放 `_ownedController`，换掉时本帧结束再毁 |
| 阈值 | `widgets/fast_slidable_pane.dart` | 露出占比、满滑、松手决策 |
| 外观 | `widgets/fast_slidable_action.dart`、`theme/fast_slidable_theme.dart` | 按钮与 ThemeExtension |
| 动画 | `motion/fast_slidable_motion.dart` | behind / drawer / scroll；满滑铺满 |
| 删除 | `widgets/fast_slidable_dismiss.dart` | 滑满后收缩行高 |
| 组 / 滚动 / 刷新 | `widgets/fast_slidable_group.dart` | 互斥、`closeOnScroll`、Refresh 锁 |

## 需要掌握的知识

- **`AnimationController` + 带符号 ratio**：绝对值走动画，符号走 `direction`，合成 `paneType`
- **`GestureDetector` 单轴识别**：水平 Slidable 不跟竖直 FastRefresh 抢手势
- **`CustomClipper`**：只露出已滑开的那一侧
- **`InheritedWidget`**：`FastSlidable.of` / pane 数据
- **`AutomaticKeepAliveClientMixin`**：`closeOnScroll: false` 时在列表里保活
- **`FastRefresh.maybeOf`**：下拉或 Header/Footer 非 `inactive` 时锁模并关闭
- **Controller 所有权**：`widget.controller ?? _ownedController`。不要 `late final` 重绑；外部实例只卸 listener，自建实例换掉后本帧再 dispose

## 满滑和删除为什么拆开

露出按钮看 `extentRatio`。继续滑过 `fullSwipe.threshold` 时主操作铺满；松手触发主操作，`dismiss: true` 再缩行。  
只配置 `FastSlidableDismiss` 时，松手超过 `dismiss.threshold` 才删除。  
不要把「露按钮」和「滑掉这一行」绑在同一个阈值上。

## 和 FastRefresh 的边界

日常组合：竖直 Refresh + 水平 Slidable。同轴（横向 Refresh + 横向 Slidable）第一版不做手势仲裁。
