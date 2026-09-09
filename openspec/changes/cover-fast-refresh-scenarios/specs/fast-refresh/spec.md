## ADDED Requirements

### Requirement: 示例入口覆盖已上线场景

Refresh 示例入口 SHALL 列出 Widget 构造、builder 构造、NestedScrollView、Locator、`refreshOnStart`、clamping 六页。每页 SHALL 只演示该场景，不新增公开 API。

#### Scenario: 入口列出六项

- **WHEN** 用户打开 Refresh 示例
- **THEN** 列表包含 Widget、Builder、Nested、Locator、refreshOnStart、clamping

### Requirement: 默认页把 AppBar 放在 FastRefresh 外面

Widget 构造与 builder 构造示例页 SHALL 把 `Scaffold.appBar` 放在 `FastRefresh` 外面，使 Header 叠在 AppBar 下方的列表区。builder 页 SHALL 仍把 `physics` 挂到 `CustomScrollView`。

#### Scenario: Builder 刷新从 AppBar 下方开始

- **WHEN** 用户打开 Builder 示例并下拉刷新
- **THEN** Header 出现在 AppBar 下方的列表顶部，而不是状态栏所在的屏幕顶

#### Scenario: Builder 仍须显式挂 physics

- **WHEN** Builder 示例构建滚动视图
- **THEN** `CustomScrollView.physics` 是 `FastRefresh.builder` 传入的 physics

### Requirement: NestedScrollView 示例使用 isNested

Nested 示例 SHALL 用 `FastRefresh.builder` 包住内层列表，设 `isNested: true`，外层钉住 AppBar，并把 FastRefresh physics 挂到内层列表。刷新 SHALL 发生在钉住顶栏下方的内层列表区。

#### Scenario: Nested 下拉在钉住顶栏下方刷新

- **WHEN** 用户打开 Nested 示例，并在内层列表越界超过 Header 触发距离
- **THEN** `onRefresh` 执行，且 Header 不钉在钉住顶栏上方的屏幕顶

### Requirement: Locator 示例把指示器放进 sliver 列表

Locator 示例 SHALL 把 Header / Footer 的 `position` 设为 locator（或 custom），并在 `CustomScrollView` 里插入 `FastHeaderLocator.sliver` / `FastFooterLocator.sliver`。Header SHALL 随列表绘制，而不是作为屏幕顶的 Stack 叠层。

#### Scenario: Locator Header 在列表内部

- **WHEN** 用户打开 Locator 示例并下拉刷新
- **THEN** Header 由滚动视图内的 locator sliver 构建

### Requirement: refreshOnStart 示例自动触发一次

`refreshOnStart` 示例 SHALL 设 `refreshOnStart: true` 且 `onRefresh` 非空。挂载后第一帧 SHALL 自动开始一次刷新。第一次回到空闲后，手动 `callRefresh` MAY 再触发一次。

#### Scenario: 首帧自动刷新

- **WHEN** 展示 `refreshOnStart` 示例
- **THEN** 无需用户下拉，`onRefresh` 执行一次

#### Scenario: 自动刷新后仍可手动刷新

- **WHEN** 自动刷新已结束，用户再触发 `callRefresh`
- **THEN** `onRefresh` 再次执行

### Requirement: clamping 示例列表不跟着越界

clamping 示例 SHALL 在 Header 上使用 `clamping: true`（若展示加载，Footer 同样）。用户下拉时，列表内容 SHALL 停在边缘，只有指示器 offset 变化。

#### Scenario: 列表像素停在边缘

- **WHEN** 用户在 clamping 示例下拉
- **THEN** 列表不随 Header 弹走；Header offset 仍增加，松手超过触发距离后 `onRefresh` 可以执行

### Requirement: 内容变长后 Footer 完成同步

加载任务结束时，若可滚动区域的 `maxScrollExtent` 已增大、当前位置不再越界，FastRefresh SHALL 重算 Footer offset，并使 Footer 回到 `inactive` 且 offset 为 `0`。

#### Scenario: 加载追加后清掉 Footer offset

- **WHEN** `onLoad` 处于 `processing`，列表增长到离开底部越界，随后加载完成
- **THEN** Footer 模式变为 `inactive`，且 Footer offset 为 `0`

### Requirement: 测试覆盖 nested、locator、refreshOnStart 与完成同步

包测试套件 SHALL 包含 `isNested` + `NestedScrollView`、locator sliver、`refreshOnStart`、Footer 完成同步的 Widget 测试。现有主路径测试 SHALL 保留。

#### Scenario: Nested 测试以 isNested 挂载

- **WHEN** Nested Widget 测试用 `isNested: true` 包住 `NestedScrollView` 并 pump `FastRefresh`
- **THEN** 树能构建，且 `callRefresh` 可以开始 `onRefresh`

#### Scenario: Locator 测试需要 locator sliver

- **WHEN** Header 使用 `position: locator`，且 `CustomScrollView` 里有 `FastHeaderLocator.sliver`
- **THEN** 下拉或 `callRefresh` 会经 locator 更新 Header 模式

#### Scenario: refreshOnStart 测试在挂载时只触发一次

- **WHEN** 测试 pump `FastRefresh(refreshOnStart: true)` 且设置了 `onRefresh`
- **THEN** 首帧之后 `onRefresh` 只被调用一次

#### Scenario: 完成同步测试清掉 Footer

- **WHEN** 测试开始加载、追加足够条目以离开越界，然后结束加载
- **THEN** Footer 快照为 `inactive` 且 offset 为 `0`

### Requirement: 文档默认 builder 把 AppBar 放在外面

中英文 Refresh 文档以及 `FastRefreshChildBuilder` 的库注释 SHALL 把第一例写成 `Scaffold.appBar` + 只含列表 sliver 的 `CustomScrollView`。折叠顶栏 SHALL 写成 Nested（`isNested: true`）或 Locator，而不是默认代码块。

#### Scenario: builder 第一例没有 SliverAppBar

- **WHEN** 读者打开「Widget 构造 vs builder」一节
- **THEN** 第一段 `FastRefresh.builder` 示例不把 `SliverAppBar` 放进 `CustomScrollView`

#### Scenario: 文档把折叠顶栏指向 Nested 或 Locator

- **WHEN** 读者想做带折叠顶栏的刷新
- **THEN** 文档让他们看 Nested 或 Locator 示例，而不是默认 builder 代码块
