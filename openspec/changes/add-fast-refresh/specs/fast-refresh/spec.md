## ADDED Requirements

### Requirement: Pull-down refresh by overscroll

`FastRefresh` SHALL start a refresh task when the user pulls the vertical scrollable past the header trigger offset and releases. If `onRefresh` is null, refresh SHALL stay disabled and the header SHALL remain inactive.

#### Scenario: Release past trigger starts refresh

- **WHEN** the user overscrolls the top by at least the header trigger offset and releases
- **THEN** the header mode becomes `processing` and `onRefresh` runs

#### Scenario: Release before trigger does not refresh

- **WHEN** the user overscrolls the top by less than the header trigger offset and releases
- **THEN** the list springs back and `onRefresh` does not run

#### Scenario: Null onRefresh disables refresh

- **WHEN** `onRefresh` is null
- **THEN** pulling the top SHALL NOT run a refresh task

### Requirement: Load more near the bottom

When `onLoad` is set and the footer has a non-null `infiniteOffset`, `FastRefresh` SHALL start a load task once the distance to the bottom is less than `infiniteOffset` (Classic footer default 70). If `onLoad` is null, load SHALL stay disabled.

#### Scenario: Approaching bottom starts load

- **WHEN** `onLoad` is set and the user scrolls so the footer edge offset is below `infiniteOffset`
- **THEN** the footer mode becomes `processing` and `onLoad` runs

#### Scenario: Null onLoad disables load

- **WHEN** `onLoad` is null
- **THEN** reaching the bottom SHALL NOT run a load task

### Requirement: Task completion results

A task SHALL finish as `success` by default, `fail` when the callback throws, or the `FastRefreshResult` returned by the callback. After `processedDuration`, the indicator SHALL return to `inactive` when overscroll is gone.

#### Scenario: Callback return value is success

- **WHEN** `onRefresh` completes and returns `FastRefreshResult.success` (or a non-result value)
- **THEN** the header result is `success` and the header returns to `inactive` after the processed animation

#### Scenario: Callback throw is fail

- **WHEN** `onRefresh` throws
- **THEN** the header result is `fail`

#### Scenario: Callback return value is noMore

- **WHEN** `onLoad` returns `FastRefreshResult.noMore`
- **THEN** the footer result is `noMore` and further load SHALL NOT start until the footer is reset

### Requirement: Controller-driven finish

When `FastRefreshController.controlFinishRefresh` or `controlFinishLoad` is true, the corresponding callback return value SHALL be ignored. The caller MUST call `finishRefresh` / `finishLoad` to complete the task.

#### Scenario: finishRefresh completes a controlled refresh

- **WHEN** `controlFinishRefresh` is true and `onRefresh` has started
- **THEN** the header stays in `processing` until `finishRefresh` is called

#### Scenario: finishLoad with noMore locks footer

- **WHEN** `finishLoad(FastRefreshResult.noMore)` is called
- **THEN** subsequent load attempts SHALL NOT run `onLoad` until `resetFooter` or a refresh reset

### Requirement: Programmatic trigger

`callRefresh` and `callLoad` SHALL animate the scrollable past the trigger offset and start the matching task when the indicator can process.

#### Scenario: callRefresh starts onRefresh

- **WHEN** `callRefresh` is invoked and refresh is enabled and idle
- **THEN** `onRefresh` runs

#### Scenario: callLoad starts onLoad

- **WHEN** `callLoad` is invoked and load is enabled and idle
- **THEN** `onLoad` runs

### Requirement: Refresh resets footer noMore

When `resetAfterRefresh` is true (the default), a successful refresh SHALL reset the footer so load can run again after `noMore`.

#### Scenario: Refresh clears noMore

- **WHEN** the footer is `noMore` and a refresh completes successfully with `resetAfterRefresh` true
- **THEN** the footer result is cleared and a later load MAY run

### Requirement: Refresh and load are mutually exclusive

While one indicator is processing, the other SHALL NOT start a task.

#### Scenario: Load blocked during refresh

- **WHEN** a refresh is in `processing`
- **THEN** scrolling to the bottom SHALL NOT start `onLoad`

### Requirement: Classic indicators render state

`FastClassicHeader` and `FastClassicFooter` SHALL show icon and text that follow the current mode and result. Callers MAY override the strings.

#### Scenario: Header shows refreshing text

- **WHEN** the header is in `processing`
- **THEN** the classic header displays its processing text
