## ADDED Requirements

### Requirement: Reset footer noMore only after successful refresh

当 `resetAfterRefresh` 为 true 时，FastRefresh MUST 仅在刷新结果为成功时清除 Footer 的 `noMore`。成功包括：回调返回 `null` 或非 `FastRefreshResult`、回调返回 `FastRefreshResult.success`，以及 `controlFinishRefresh` 为 true 时调用 `finishRefresh(FastRefreshResult.success)`（含 `force: true`）。回调抛错、返回 `fail` / `noMore`，或 `finishRefresh(fail|noMore)` 时，MUST NOT 清除 Footer 的 `noMore`。`controlFinishRefresh` 为 true 时，包装后的 `onRefresh` 返回后 MUST NOT 立刻重置 Footer。

#### Scenario: Successful refresh clears footer noMore

- **WHEN** Footer 已处于 `noMore`，且 `resetAfterRefresh` 为 true
- **AND** `onRefresh` 返回 `FastRefreshResult.success`（或 `null`）
- **THEN** Footer 的 `noMore` 被清除，之后仍可加载

#### Scenario: Failed refresh keeps footer noMore

- **WHEN** Footer 已处于 `noMore`，且 `resetAfterRefresh` 为 true
- **AND** `onRefresh` 返回 `FastRefreshResult.fail` 或抛错
- **THEN** Footer 仍保持 `noMore`

#### Scenario: Manual finishRefresh success resets footer

- **WHEN** `controlFinishRefresh` 为 true，Footer 已处于 `noMore`，且 `resetAfterRefresh` 为 true
- **AND** 调用方在刷新过程中调用 `finishRefresh(FastRefreshResult.success)`
- **THEN** Footer 的 `noMore` 被清除

#### Scenario: Manual finishRefresh fail keeps footer noMore

- **WHEN** `controlFinishRefresh` 为 true，Footer 已处于 `noMore`，且 `resetAfterRefresh` 为 true
- **AND** 调用方调用 `finishRefresh(FastRefreshResult.fail)`
- **THEN** Footer 仍保持 `noMore`

### Requirement: Unbind controller when FastRefresh is disposed or replaced

`FastRefresh` MUST 在 State `dispose` 时，若当前 `controller` 仍绑定该 State，则将其解绑。更换 `controller` 时 MUST 先解绑旧控制器再绑定新控制器。解绑后，对该控制器调用 `callRefresh` / `callLoad` / `finishRefresh` / `finishLoad` MUST 为空操作，且 MUST NOT 访问已销毁的 notifier。

#### Scenario: finishRefresh after dispose is a no-op

- **WHEN** 带 `FastRefreshController` 的 `FastRefresh` 已从树中移除
- **AND** 调用方随后调用 `controller.finishRefresh()`
- **THEN** 不抛错，也不再改指示器状态

#### Scenario: Replacing controller unbinds the previous one

- **WHEN** `FastRefresh` 的 `controller` 从 A 换成 B
- **AND** 随后对 A 调用 `callRefresh`
- **THEN** A 为空操作；B 仍能触发刷新

### Requirement: FastRefreshTheme styles Classic and Material indicators

系统 MUST 提供 `FastRefreshTheme`（`ThemeExtension`）。Classic 文案、文字/图标样式、进度圈尺寸，以及 Material 指示器颜色，MUST 按以下顺序解析：组件构造参数（非 null）→ 已注册的 `FastRefreshTheme` → 按 `ThemeData.brightness` 回退的 `light` / `dark`。未注册 Theme 且未传文案时，Classic MUST 继续使用现有英文默认文案。`FastRefreshTheme` MUST NOT 改变触发距离、弹簧或其它物理参数。

#### Scenario: Widget text overrides theme

- **WHEN** `ThemeData.extensions` 挂了中文 `FastRefreshTheme`
- **AND** `FastClassicHeader(dragText: '自定义')` 被使用
- **THEN** drag 文案为「自定义」，其它未传文案使用 Theme 中的值

#### Scenario: Unstyled Classic keeps English defaults

- **WHEN** 未注册 `FastRefreshTheme`，且 Classic Header / Footer 未传文案
- **THEN** 文案仍为现有英文默认值（例如 `Pull to refresh` / `No more`）

#### Scenario: Material color follows theme

- **WHEN** 已注册 `FastRefreshTheme` 并设置 `indicatorColor`
- **AND** 使用 `FastMaterialHeader` 且未传 `color`
- **THEN** 指示器使用 Theme 的 `indicatorColor`

### Requirement: Material header and footer use SDK progress indicators

系统 MUST 提供 `FastMaterialHeader` 与 `FastMaterialFooter`。两者默认 `triggerOffset` 为 70、`processedDuration` 为 zero。Header 默认 `clamping` 为 true。Footer 默认 `clamping` 为 false（与 `infiniteOffset` 不能同时为 clamping 的现有约束一致），触底加载默认与 Classic Footer 相同（`infiniteOffset` 为 70）。Header 在未进入 `ready` / `processing` 时 MUST 用越界比例驱动 `RefreshProgressIndicator` 的确定进度；进入 `ready` / `processing` 后 MUST 改为不确定进度。Footer 使用 `CircularProgressIndicator`。默认 Header / Footer 工厂 MUST 仍返回 Classic。不引入 Flutter SDK 以外的依赖。

#### Scenario: Material header clamps the list

- **WHEN** `FastRefresh` 使用默认参数的 `FastMaterialHeader`
- **AND** 用户下拉超过触发距离
- **THEN** 列表本身不跟着越界（clamping），指示器显示进度并在松手后进入刷新

#### Scenario: Default refresh skin remains Classic

- **WHEN** `FastRefresh` 未传 `header` / `footer`
- **THEN** 仍使用 `FastClassicHeader` / `FastClassicFooter`

#### Scenario: Material footer still infinite-loads

- **WHEN** 使用默认 `FastMaterialFooter` 且提供 `onLoad`
- **AND** 列表滚动到距底部小于 70
- **THEN** 触发加载，不必先拉过阈值再松手

### Requirement: FastPagingList fetches pages without a subclass

系统 MUST 提供 `FastPagingPage<T>` 与具体组件 `FastPagingList<T>`。调用方 MUST 能只传 `fetchPage` 与 `itemBuilder` 完成刷新与加载。刷新 MUST 请求 `firstPage`（默认 1）并替换列表；加载 MUST 请求下一页并追加。`fetchPage` 抛错时 MUST 保留已有数据，并由 FastRefresh 记为失败。`isNoMore` MUST 按此优先级：显式 `hasMore` → 基类的 `total` / `page`+`totalPage` → 最近一次成功页的 `items` 为空。`FastPagingList` MUST 允许构造期传入 `header` / `footer`，且 `FastPaging` 抽象基类仍然可用。

#### Scenario: First page and load more

- **WHEN** `FastPagingList` 的 `fetchPage(1)` 返回 10 条且 `total` 为 25
- **AND** 随后触发加载，`fetchPage(2)` 再返回 10 条
- **THEN** 列表共 20 条，Footer 尚未锁定 `noMore`

#### Scenario: Total reached marks noMore

- **WHEN** 已加载条数达到 `FastPagingPage.total`
- **THEN** Footer 结果为 `noMore`，不再触发 `fetchPage`

#### Scenario: Empty page marks noMore

- **WHEN** 未提供 `total` / `totalPage` / `hasMore`
- **AND** 某次成功的 `fetchPage` 返回空 `items`
- **THEN** 视为没有更多

#### Scenario: Fetch error keeps previous items

- **WHEN** 列表已有第一页数据
- **AND** 下一次 `fetchPage` 抛错
- **THEN** 已有条目仍在，对应刷新或加载结果为 `fail`

#### Scenario: Header override without subclass

- **WHEN** `FastPagingList(header: FastMaterialHeader(), fetchPage: ..., itemBuilder: ...)`
- **THEN** 刷新指示器为 Material，且不必再写 `FastPaging` 子类
