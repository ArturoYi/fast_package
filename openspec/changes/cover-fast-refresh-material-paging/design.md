## Context

FastRefresh 已对齐 EasyRefresh 的物理、状态机、Classic、Locator、builder、二楼和 `FastPaging`。默认皮肤只有 Classic；分页必须继承 `FastPaging` 并实现 `page` / `total` / `count` 等抽象成员。Classic 文案硬编码英文。`resetAfterRefresh` 在 `onRefresh` 返回后无条件 `_reset()` Footer，与文档「刷新成功才清 noMore」不一致。`FastRefresh.dispose` 不解绑 controller，拆页后再 `finishRefresh` 会打到已销毁的 notifier。

约束：只依赖 Flutter SDK；默认 Header / Footer 仍是 Classic；不搬 Bezier / Phoenix / Taurus / Delivery；不引入独立 l10n delegate。Theme 解析对齐已有的 `FastToastTheme` / `FastLoadingTheme` / `FastShimmerTheme`。

## Goals / Non-Goals

**Goals:**

- 提供可选用的 Material 薄皮肤，默认 `clamping`，看起来像系统下拉刷新。
- 提供 `FastPagingList<T>`，用 `fetchPage` + `itemBuilder` 完成日常分页。
- Classic / Material 可走 `FastRefreshTheme`。
- `resetAfterRefresh` 只在刷新成功时生效；controller 在 dispose / 更换时解绑。
- 分阶段实现：先正确性，再 Theme，再 Material，再 PagingList，最后文档与示例。

**Non-Goals:**

- 不改变默认皮肤（仍为 Classic）。
- 不搬 EasyRefresh 其余皮肤，不做 Cupertino 水滴。
- 不重写物理 / 状态机，不改 `FastPaging` 继承模型（只在其上加具体子类）。
- 不上 `LocalizationsDelegate`；不做 Footer 失败重试、Grid、Semantics（可后续另开 change）。
- 不改 LICENSE 结构（MIT 致谢已在 docs credits）。

## Decisions

### 1. 实现顺序：正确性 → Theme → Material → PagingList → 文档

先修 `resetAfterRefresh` 与 controller 解绑，PagingList 的首页 `noMore` 才不会踩旧行为。Theme 先于 Material，皮肤颜色走同一套解析。文档和 example 放最后，避免 API 未定就改两份文档。

备选：先做 Material / PagingList 再回头修正确性。否决：PagingList 依赖「刷新成功才 reset Footer」，先修成本更低。

### 2. Material 只做转圈，不做 Bezier 背景

`FastMaterialHeader` / `FastMaterialFooter` 继承现有 Header / Footer 协议。

默认值：

| 项 | Header | Footer |
| --- | --- | --- |
| `clamping` | `true` | `false`（现有协议禁止 `clamping` + `infiniteOffset` 同时开） |
| `triggerOffset` | `70`（与 Classic 一致，避免两套阈值） | `70` |
| `processedDuration` | `Duration.zero` | `Duration.zero` |
| `position` | `above` | `above` |
| `infiniteOffset` | `null` | `70`，与 Classic Footer 同手势，换皮不改触底加载 |
| 指示器 | `RefreshProgressIndicator`（跟手 value） | `CircularProgressIndicator` |

跟手：`offset / actualTriggerOffset` 映射到 `RefreshProgressIndicator.value`（未进入 processing 时）；`ready` / `processing` 改为 indeterminate。颜色默认 `ThemeData.colorScheme.primary`，可被 `FastRefreshTheme` 与构造参数覆盖。

备选：用 `CircularProgressIndicator` 当 Header。否决：系统下拉是 `RefreshProgressIndicator` 的月牙，更像「系统刷新」。

备选：`triggerOffset: 100` 对齐 EasyRefresh MaterialHeader。否决：本包 Classic 已是 70，两套默认会让换皮改变触发手感。

### 3. `FastRefreshTheme` 只管外观，不管物理

`ThemeExtension<FastRefreshTheme>`，解析顺序与 Toast 相同：

1. 组件构造参数（`dragText`、`color` 等非 null）
2. `ThemeData.extensions` 里的 `FastRefreshTheme`
3. 按 `brightness` 回退到 `light` / `dark`

字段（保持薄）：

- Classic：`dragText` / `armedText` / `readyText` / `processingText` / `processedText` / `noMoreText` / `failedText` / `messageText`（Header 与 Footer 各一套，或 `headerTexts` / `footerTexts` 小组）
- 共用：`textStyle` / `messageStyle` / `iconTheme` / `progressIndicatorSize` / `progressIndicatorStrokeWidth`
- Material：`indicatorColor` / `backgroundColor`

未注册 Theme 时，Classic 文案仍为当前英文默认，避免无 Theme 的现有 example / 测试大面积变文案。要中文默认的应用在 `ThemeData.extensions` 里挂一份即可。

备选：按 `Localizations.localeOf` 自动中英。否决：和包内其它 Theme 不一致，也更容易让测试依赖 locale。

### 4. `resetAfterRefresh` 以「成功」为准，分两条路径

「成功」= 回调返回 `null` / 非 `FastRefreshResult`（现状视为 success），或返回 `FastRefreshResult.success`。`fail` / `noMore` / 抛错不重置。

- **未接管完成**（`controlFinishRefresh == false`）：在包装后的 `_onRefresh` 里根据返回值（及 catch→fail）决定是否 `_footerNotifier._reset()`。
- **接管完成**（`controlFinishRefresh == true`）：包装回调里**不再** reset。在 `finishRefresh` 且 result 为 `success` 时，若 `resetAfterRefresh` 为 true，再 `_reset()` Footer。

`force: true` 的 `finishRefresh` 同样遵守「仅 success 才 reset」。

备选：两条路径都在回调返回后 reset。否决：接管完成时回调返回值无效，无法知道成败。

### 5. Controller 解绑只清「仍指向自己」的引用

`FastRefreshController` 增加 `_unbind(_FastRefreshState state)`：仅当 `_state == state` 时置 `null`。

- `dispose`：先 `_unbind(this)` 再拆 notifier。
- `didUpdateWidget`：controller 被替换时，旧的 `_unbind(this)`，新的 `_bind(this)`。
- 现有 `controller.dispose()` 仍把 `_state = null`。

解绑后 `callRefresh` / `finishRefresh` 为空操作（已有 `?.`）。不在解绑后 assert，避免测试 tearDown 噪音。

### 6. `FastPagingList` 是 `FastPaging<List<T>, T>` 的具体子类

对外最小 API：

```dart
FastPagingList<Item>(
  fetchPage: (page) async => FastPagingPage(items: ..., page: page, total: ...),
  itemBuilder: (context, index, item) => ...,
)
```

`FastPagingPage<T>`：`items`、`page`，可选 `total` / `totalPage` / `hasMore`。

`isNoMore` 优先级：

1. `hasMore != null` → `!hasMore`
2. 否则沿用基类：`total` 优先，再 `page >= totalPage`
3. 若以上都没有：最近一次成功请求的 `items.isEmpty` 视为没有更多（含首页空列表）

`firstPage` 默认 `1`。刷新请求 `firstPage`，加载请求 `(page ?? firstPage) + 1`。`fetchPage` 抛错不 `setState`，保留旧数据，由 FastRefresh 记 `fail`。

构造期可传 `header` / `footer` / `enableRefresh` / `enableLoad`，以及现有 `FastPaging` 已有的 refresh 旋钮。`buildHeader` / `buildFooter` 优先用传入的实例。这样换 Material 不必再开子类。

备选：独立 StatefulWidget 复制一份 FastPaging 生命周期。否决：`noMore` / 空态 / refreshOnStart 已在基类，复制会分叉。

备选：推断 `items.length < pageSize`。否决：`pageSize` 与接口不一致时会提前锁 Footer；空页规则更简单，调用方也可用 `hasMore` / `total` 显式控制。

## Risks / Trade-offs

- [失败刷新不再清 Footer noMore] → 与文档一致，但是行为变化。文档和 CHANGELOG 写明；测试覆盖 fail / success / 接管完成三条路径。
- [未给 total/hasMore 时靠空页结束] → 接口若最后一页仍返回占位空数组以外的短页，会继续加载。文档要求用 `total` / `hasMore`；测试覆盖空页与 `hasMore: false`。
- [Material Footer 仍默认可触底加载] → 和「系统刷新」不完全对称，但换皮不改手势。文档写明 Footer 职责仍是加载。
- [Theme 默认英文] → 中文应用要挂 Theme 或继续传参。example / 文档给一份中文 Theme 示例，不改无 Theme 时的默认值。
- [PagingList 固定 `List<T>`] → 不能直接表达「data 是分页响应对象」。复杂结构继续用 `FastPaging` 子类。

## Migration Plan

1. 先合正确性：失败刷新后 Footer `noMore` 会保留。若业务依赖「失败也解锁 Footer」，改为在 fail 分支显式 `resetFooter()`。
2. Theme / Material / PagingList 均为增量，不改现有调用。
3. 回滚：各阶段独立可回退；正确性修复与文档绑定，回滚需同时改文档。

## Open Questions

- 无。Material 阈值、空页规则、Theme 不自动跟 locale，均已在 Decisions 拍板。实现中若 `RefreshProgressIndicator` 在横向/Footer 上难看，Header 用 Refresh、Footer 用 Circular，不扩大皮肤范围。
