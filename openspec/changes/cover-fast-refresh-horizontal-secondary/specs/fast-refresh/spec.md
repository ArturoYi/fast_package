## ADDED Requirements

### Requirement: 示例入口列出横向与二楼

Refresh 示例入口 SHALL 在现有六页之外列出横向、二楼两页。每页 SHALL 只演示该场景，不新增公开 API。

#### Scenario: 入口包含横向与二楼

- **WHEN** 用户打开 Refresh 示例
- **THEN** 列表包含横向与二楼两项，且仍包含 Widget、Builder、Nested、Locator、refreshOnStart、clamping

### Requirement: 横向列表示例按横轴刷新

横向示例 SHALL 使用 `scrollDirection: Axis.horizontal` 的 `ListView`（或同页切换的 `PageView`），并把 `Scaffold.appBar` 放在 `FastRefresh` 外面。`PageView` 展示时 Footer SHALL 将 `infiniteOffset` 设为 `null`。

#### Scenario: 横向 ListView 可刷新

- **WHEN** 用户打开横向示例并沿水平方向越界超过 Header 触发距离后松开
- **THEN** `onRefresh` 执行，且 Header 快照的 `axis` 为 `Axis.horizontal`

#### Scenario: PageView 不因翻页自动加载

- **WHEN** 横向示例切换到 `PageView` 且用户翻到下一页
- **THEN** 仅翻页本身 SHALL NOT 触发 `onLoad`

### Requirement: Header 二楼示例可打开并关闭

二楼示例 SHALL 使用 `FastSecondaryBuilderHeader` 包装现有 Header，设置 `secondaryTriggerOffset`，`FastRefresh.clipBehavior` 为 `Clip.none`，并在滚动视图内放置 Header locator。用户或控制器打开二楼后 SHALL 能通过 `closeHeaderSecondary`（或返回手势绑定的同一调用）关闭。

#### Scenario: 控制器打开 Header 二楼

- **WHEN** 用户在二楼示例触发 `openHeaderSecondary`
- **THEN** Header 模式变为 `secondaryOpen`，二楼内容可见

#### Scenario: 控制器关闭 Header 二楼

- **WHEN** Header 已处于 `secondaryOpen`，用户触发 `closeHeaderSecondary`
- **THEN** Header 回到 `inactive`，列表恢复可滚

#### Scenario: 拉过二楼阈值松手打开

- **WHEN** 用户下拉超过 `secondaryTriggerOffset` 后松开
- **THEN** Header 进入 `secondaryReady` 或 `secondaryOpen`，而不是普通 `processing` 刷新

### Requirement: 测试覆盖横向与 Header 二楼

包测试套件 SHALL 包含横向 `ListView` 与 Header 二楼的 Widget 测试。现有主路径与上一轮场景测试 SHALL 保留。

#### Scenario: 横向测试记录横轴

- **WHEN** 测试 pump 带横向 `ListView` 的 `FastRefresh` 并水平拖过触发距离
- **THEN** Header 快照的 `axis` 为 `Axis.horizontal`，且模式不是 `inactive`

#### Scenario: 横向 callRefresh 能跑

- **WHEN** 横向测试调用 `callRefresh`
- **THEN** `onRefresh` 执行

#### Scenario: 二楼测试能打开再关闭

- **WHEN** 测试配置 `secondaryTriggerOffset` 后调用 `openHeaderSecondary`，再调用 `closeHeaderSecondary`
- **THEN** 打开后 Header 为 `secondaryOpen`；关闭后为 `inactive` 且 offset 为 `0`

#### Scenario: 未配置二楼时打开为空操作

- **WHEN** Header 未设置 `secondaryTriggerOffset`，测试调用 `openHeaderSecondary`
- **THEN** Header 不进入 `secondaryOpen`

### Requirement: 文档写出横向与二楼配方

中英文 Refresh 文档 SHALL 说明横向列表（`scrollDirection`、可选 `triggerAxis`、`PageView` 须关闭 Footer 无限加载）以及 Header 二楼（`secondaryTriggerOffset`、`clipBehavior: Clip.none`、locator、与 `infiniteOffset` 互斥、`openHeaderSecondary` / `closeHeaderSecondary`），并指向对应 example 页。

#### Scenario: 文档有横向小节

- **WHEN** 读者打开 Refresh 文档
- **THEN** 能看到横向用法，并知道 example 路径

#### Scenario: 文档有二楼小节

- **WHEN** 读者打开 Refresh 文档
- **THEN** 能看到二楼四个参数与开关 API，并知道 example 路径
