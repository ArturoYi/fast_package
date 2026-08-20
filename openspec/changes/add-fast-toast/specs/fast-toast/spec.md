## ADDED Requirements

### Requirement: Context-free toast API

The package SHALL export two top-level show functions, `showToast` and `showCustomToast`, that enqueue and display toasts without a `BuildContext`. The package MUST NOT expose a toast type enum or typed helpers such as `success`, `error`, `info`, or `custom`.

#### Scenario: Show a plain message

- **WHEN** the app has mounted `FastToastOverlay` and the caller invokes `showToast('saved')`
- **THEN** a toast containing the text `saved` becomes visible on the overlay

#### Scenario: Show a custom widget

- **WHEN** the app has mounted `FastToastOverlay` and the caller invokes `showCustomToast` with a widget containing text `custom-body`
- **THEN** that widget SHALL be visible on the overlay

#### Scenario: Call without BuildContext

- **WHEN** `showToast` or `showCustomToast` is invoked from a callback that has no widget `BuildContext`
- **THEN** the call SHALL NOT require a `BuildContext` argument and SHALL still enqueue the toast

### Requirement: Overlay host mount

The package SHALL provide `FastToastOverlay` to wrap the `MaterialApp.builder` child. The overlay host SHALL register its `OverlayState` with the toast controller on attach and unregister on dispose without crashing the app.

#### Scenario: Mount via MaterialApp.builder

- **WHEN** the app wraps the builder child with `FastToastOverlay`
- **THEN** subsequent `showToast` calls display on that overlay and remain visible across route pushes and pops

#### Scenario: Show before overlay is mounted

- **WHEN** `showToast` is called and no overlay host is attached
- **THEN** the call SHALL NOT throw, and the toast SHALL appear after a host attaches if it is still pending

#### Scenario: Host dispose keeps pending queue

- **WHEN** `FastToastOverlay` is disposed while toasts are pending
- **THEN** the visible entry SHALL be removed and pending requests SHALL remain until a host attaches again or `FastToast.dismissAll` is called

### Requirement: FIFO single-slot queue

The system SHALL display at most one toast at a time. Additional requests from either `showToast` or `showCustomToast` MUST wait in a shared FIFO queue and start only after the current toast has finished its exit animation (or been dismissed).

#### Scenario: Second toast waits

- **WHEN** a toast is already showing and another `showToast` is invoked
- **THEN** the second message SHALL NOT overlap the first and SHALL appear after the first toast is dismissed

#### Scenario: Sequential dequeue across APIs

- **WHEN** `showToast('a')`, `showCustomToast(...)`, and `showToast('c')` are enqueued while none is showing
- **THEN** they SHALL appear one after another in enqueue order

### Requirement: Pending queue capacity

The pending queue (excluding the currently shown toast) MUST cap at 5 items. When the cap would be exceeded, the system SHALL drop the oldest pending item and then enqueue the new request.

#### Scenario: Drop oldest pending when full

- **WHEN** 5 toasts are pending (plus any currently shown toast) and another toast is enqueued
- **THEN** the oldest pending toast SHALL be discarded and the new toast SHALL be appended

### Requirement: Duration, position, and dismissible config

`FastToastConfig` SHALL control duration, screen position, and whether the toast content can be tapped to dismiss. Defaults MUST be duration 2000ms, position `FastToastPosition.center`, and `dismissible: false`. The same config SHALL apply to both `showToast` and `showCustomToast`.

#### Scenario: Custom duration

- **WHEN** a toast is shown with `FastToastConfig(duration: Duration(seconds: 3))`
- **THEN** the toast SHALL remain until approximately 3 seconds have elapsed, then play exit animation and remove

#### Scenario: Top and bottom positions

- **WHEN** a toast is shown with `FastToastPosition.top` or `FastToastPosition.bottom`
- **THEN** the toast panel SHALL align to the top-center or bottom-center of the overlay with a gap beyond the window view padding

#### Scenario: Keyboard does not cover bottom toast

- **WHEN** a bottom toast is visible and the keyboard view insets increase
- **THEN** the toast SHALL shift up by the insets on a compositing layer without requiring the toast widget to rebuild its layout for that animation

#### Scenario: Tap to dismiss

- **WHEN** `dismissible` is true and the user taps the toast content
- **THEN** the current toast SHALL dismiss (including exit animation) and the next pending toast MAY then show

#### Scenario: Outside taps pass through

- **WHEN** a toast is visible and the user taps outside the toast content
- **THEN** the tap SHALL reach widgets beneath the overlay and SHALL NOT dismiss the toast unless `dismissible` handling is on the content itself

### Requirement: Manual dismiss

`FastToast.dismiss` SHALL close the current toast if one is showing. `FastToast.dismissAll` SHALL clear the pending queue and immediately remove the current overlay entry.

#### Scenario: Dismiss current then show next

- **WHEN** a toast is showing, at least one toast is pending, and `FastToast.dismiss()` is called
- **THEN** the current toast SHALL exit and the next pending toast SHALL show afterward

#### Scenario: Dismiss all

- **WHEN** toasts are showing and/or pending and `FastToast.dismissAll()` is called
- **THEN** no toast SHALL remain visible and `FastToast.pendingCount` SHALL be 0

#### Scenario: Dismiss when idle

- **WHEN** no toast is showing and `FastToast.dismiss()` is called
- **THEN** the call SHALL be a no-op and SHALL NOT throw

### Requirement: Default text theme

The package SHALL provide `FastToastTheme` as a `ThemeExtension` with light and dark defaults for the `showToast` text panel (background, text style, radius, padding, box shadow). Visual resolution MUST prefer a registered theme extension, then fall back to light/dark defaults from `ThemeData.brightness`. `showCustomToast` MUST NOT wrap the caller's widget in that default panel chrome.

#### Scenario: Register theme extension

- **WHEN** `ThemeData.extensions` includes a custom `FastToastTheme` and the caller invokes `showToast('hello')`
- **THEN** the text toast SHALL use that theme's background color, text style, radius, padding, and box shadow

#### Scenario: Fallback without extension

- **WHEN** no `FastToastTheme` is registered and the caller invokes `showToast('hello')`
- **THEN** the text toast SHALL still render using built-in light or dark defaults

#### Scenario: Custom toast keeps caller chrome

- **WHEN** the caller invokes `showCustomToast` with a widget that has its own background
- **THEN** the host SHALL NOT wrap it in the default `showToast` panel decoration

### Requirement: Motion and accessibility

Each toast SHALL animate in and out with a short fade, plus a slight slide when the position is top or bottom. `showToast` MUST expose the message to assistive technologies as a live region. Animation controllers MUST be disposed when the overlay entry is removed.

#### Scenario: Exit animation before removal

- **WHEN** a toast reaches the end of its duration
- **THEN** it SHALL play a reverse fade (and slide if applicable) before the overlay entry is removed

#### Scenario: Screen reader label for text toast

- **WHEN** `showToast('network error')` is shown
- **THEN** semantics SHALL include that message as a live region label

### Requirement: Public barrel exports

The package barrel `lib/fast_package.dart` SHALL export `showToast`, `showCustomToast`, `FastToast`, `FastToastOverlay`, `FastToastTheme`, `FastToastConfig`, and `FastToastPosition`. It MUST NOT export a toast type enum, and MUST NOT export internal queue, controller, or view types as part of the documented public surface.

#### Scenario: Import from package root

- **WHEN** an app imports `package:fast_package/fast_package.dart`
- **THEN** it SHALL be able to reference `showToast`, `showCustomToast`, `FastToast`, `FastToastOverlay`, `FastToastTheme`, `FastToastConfig`, and `FastToastPosition` without additional libraries
