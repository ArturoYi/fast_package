## 1. 正确性：controller 解绑

- [x] 1.1 `FastRefreshController` 增加 `_unbind`：仅当 `_state` 仍是传入的 State 时置 `null`
- [x] 1.2 `FastRefresh` dispose 时先解绑当前 controller；`didUpdateWidget` 更换 controller 时先解绑旧的再绑定新的
- [x] 1.3 测试：树移除后 `finishRefresh` / `callRefresh` 不抛错；controller 从 A 换成 B 后，A 为空操作、B 仍可用

## 2. 正确性：resetAfterRefresh 仅成功时生效

- [x] 2.1 未接管完成时：包装 `_onRefresh` 仅在结果为成功（`null` / 非 Result / `success`）时 `_reset()` Footer；`fail` / `noMore` / 抛错不重置
- [x] 2.2 接管完成时：包装回调不再 reset；`finishRefresh(success)`（含 `force`）且 `resetAfterRefresh` 为 true 时再 reset
- [x] 2.3 测试覆盖：成功清 noMore、失败保留、`finishRefresh(success)` 清、`finishRefresh(fail)` 保留

## 3. FastRefreshTheme

- [x] 3.1 新增 `fast_refresh_theme.dart`（`part of`）：`ThemeExtension`，`light` / `dark`，`of` / `resolve` / `copyWith` / `lerp`，字段按 design（Classic 文案分组、样式、Material 颜色）
- [x] 3.2 Classic Header / Footer 解析文案与样式：构造参数 → Theme → 现有英文默认；不改变物理默认值
- [x] 3.3 测试：未挂 Theme 仍是英文默认；挂 Theme 后未传参走 Theme；构造参数覆盖 Theme

## 4. Material 薄皮肤

- [x] 4.1 新增 `FastMaterialHeader` / `FastMaterialFooter`：Header 默认 `clamping: true`，Footer 默认 `clamping: false`（现有协议禁止与 `infiniteOffset` 同时开）、`triggerOffset: 70`、`processedDuration: Duration.zero`；Header 用 `RefreshProgressIndicator`（跟手确定进度，ready/processing 不确定）；Footer 用 `CircularProgressIndicator`，默认 `infiniteOffset: 70`
- [x] 4.2 颜色走 Theme `indicatorColor` / `backgroundColor`，构造参数可覆盖；`FastRefresh.defaultHeaderBuilder` 仍返回 Classic
- [x] 4.3 测试：默认仍是 Classic；Material Header 为 clamping；Material Footer 距底小于 70 触发 `onLoad`

## 5. FastPagingList

- [x] 5.1 新增 `FastPagingPage<T>`（`items` / `page`，可选 `total` / `totalPage` / `hasMore`）
- [x] 5.2 新增 `FastPagingList<T> extends FastPaging<List<T>, T>`：`fetchPage` + `itemBuilder`；`firstPage` 默认 1；刷新替换、加载追加；抛错不 `setState`；构造可传 `header` / `footer` / `enableRefresh` / `enableLoad`
- [x] 5.3 `isNoMore`：`hasMore` → 基类 `total` / `page`+`totalPage` → 最近成功页 `items.isEmpty`
- [x] 5.4 测试：首页 + 加载未满；`total` 到齐锁 noMore；空页锁 noMore；`fetchPage` 抛错保留旧数据且 fail；传入 `FastMaterialHeader` 无需再写子类

## 6. 示例、文档、changelog

- [x] 6.1 example 刷新入口增加 Material 页（clamping + 系统转圈）；Paging 页增加 `FastPagingList` 演示（可与现有子类示例并列或加切换）
- [x] 6.2 中英文 `docs/ui/refresh.md`：Material、FastPagingList、Theme、`resetAfterRefresh` 仅成功、controller 解绑后为空操作；credits 更新改善说明
- [x] 6.3 `CHANGELOG.md` 记录本批能力；`LEARN.md` 补 Theme / Material / PagingList 一句指向
