---
title: Debounce, Throttle, and Rate Limit
outline: [2, 3]
---

## Overview {#overview}

Three static utilities built on `dart:async` `Timer` to tame high-frequency side effects (rapid taps, search input, scroll handlers). Each uses a `tag` so different call sites do not interfere.

| Utility | Behavior | Typical use |
| --- | --- | --- |
| `FastDebounce` | Each call resets a **quiet timer**; only the **last** call runs after quiet time | Search-as-you-type, resize |
| `FastThrottle` | **At most one** run per **throttle window** (first call in the window runs immediately; extra in-window calls are **dropped**) | Submit buttons, likes |
| `FastRateLimit` | **First** call runs immediately and starts **time windows** of length `duration`; in-window calls **defer**—only the **latest** callback runs at the **next window boundary** | Coalesced search submit, scroll pagination |

```dart
import 'package:fast_package/fast_package.dart';
```

---

## FastDebounce {#fast-debounce}

Each call resets the quiet timer; `onExecute` runs only after `duration` passes with no further calls. When `duration` is `Duration.zero`, the callback runs immediately and any pending timer is cleared.

### Basic usage {#fast-debounce-example}

Search field: request after the user pauses typing.

::: code-group

```dart [Widget]
TextField(
  onChanged: (keyword) {
    FastDebounce.debounce(
      tag: 'search-suggest',
      duration: const Duration(milliseconds: 300),
      onExecute: () => fetchSuggestions(keyword),
    );
  },
);

@override
void dispose() {
  FastDebounce.cancel('search-suggest');
  super.dispose();
}
```

```dart [Controller]
void onKeywordChanged(String keyword) {
  FastDebounce.debounce(
    tag: 'search-suggest',
    duration: const Duration(milliseconds: 300),
    onExecute: () => fetchSuggestions(keyword),
  );
}

void dispose() {
  FastDebounce.cancel('search-suggest');
}
```

:::

### API reference {#fast-debounce-api}

---

#### `FastDebounce.debounce` {#fast-debounce-debounce}

Delays execution on every call; runs only the **last** `onExecute` after quiet time with no new calls.

```dart
FastDebounce.debounce(
  tag: 'search-suggest',
  duration: const Duration(milliseconds: 300),
  onExecute: () {
    // runs after quiet time
  },
);
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Instance id. Same `tag` shares one timer chain; use different tags per feature (e.g. `'search-suggest'`). |
| `duration` | `Duration` | yes | Quiet period. Each call **resets** the timer; `onExecute` runs only after `duration` with no further calls. `Duration.zero` runs immediately and clears any pending timer. |
| `onExecute` | `void Function()` | yes | Side effect after quiet time (`FastDebounceVoidCallback`). |

---

#### `FastDebounce.fire` {#fast-debounce-fire}

Runs the cached `onExecute` for `tag` **now** (e.g. user taps “Search now”), without waiting for quiet time.  
`fire` does **not** stop the quiet timer already scheduled for that `tag`: if there are no further `debounce` calls, the timer still fires and `onExecute` runs **again**. To run once now **and** prevent that second run at expiry, call `fire` then `cancel` with the same `tag`.

```dart
FastDebounce.fire('search-suggest');

// Run now, and do not run again when quiet time expires:
FastDebounce.fire('search-suggest');
FastDebounce.cancel('search-suggest');
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Debounce instance to flush immediately. |

---

#### `FastDebounce.cancel` {#fast-debounce-cancel}

Cancels the timer for `tag` and removes its record; a pending `onExecute` will **not** run. Call from `dispose` to avoid leaks or callbacks after navigation.

```dart
FastDebounce.cancel('search-suggest');
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Debounce instance to cancel. |

---

#### `FastDebounce.cancelAll` {#fast-debounce-cancel-all}

Cancels **all** active debounces (e.g. on global logout or app reset).

```dart
FastDebounce.cancelAll();
```

No parameters.

---

#### `FastDebounce.count` {#fast-debounce-count}

How many debounces are still waiting for quiet time (debugging / monitoring).

|  | Type | Description |
| --- | --- | --- |
| Return value | `int` (getter) | Count of debounce instances with an active timer. |

---

## FastThrottle {#fast-throttle}

Maintains one **throttle window** per `tag` (length `duration`). The **first** call in a window runs `onExecute` immediately; further calls in the same window are **dropped** (`skipped == true`). Optionally runs `onAfter` when the window ends.

### Basic usage {#fast-throttle-example}

Submit button: ignore double-taps within the window.

::: code-group

```dart [Widget]
FilledButton(
  onPressed: () {
    FastThrottle.throttle(
      tag: 'checkout-submit',
      duration: const Duration(seconds: 1),
      onExecute: () => placeOrder(),
    );
  },
  child: const Text('Place order'),
);
```

```dart [Controller]
void submitOrder() {
  FastThrottle.throttle(
    tag: 'checkout-submit',
    duration: const Duration(seconds: 1),
    onExecute: () => placeOrder(),
  );
}
```

:::

### API reference {#fast-throttle-api}

---

#### `FastThrottle.throttle` {#fast-throttle-throttle}

Keeps one **throttle window** per `tag`: the **first** call in a window runs `onExecute` immediately; duplicates in the same window are dropped.

```dart
final skipped = FastThrottle.throttle(
  tag: 'checkout-submit',
  duration: const Duration(seconds: 1),
  onExecute: () => placeOrder(),
  onAfter: () {}, // optional
);
// skipped == true: still inside the window; this call was dropped
// skipped == false: new window started; onExecute already ran
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Instance id. At most one active window per `tag` at a time. |
| `duration` | `Duration` | yes | Window length. In-window calls do **not** extend the window. |
| `onExecute` | `void Function()` | yes | Runs **immediately** on the **first** call in a new window (`FastThrottleVoidCallback`). |
| `onAfter` | `void Function()?` | no | Runs when the window ends (timer fires); e.g. re-enable a button. |

| Return value | Type | Description |
| --- | --- | --- |
| `true` | `bool` | Name it `skipped`: call fell inside an existing window; `onExecute` did **not** run. |
| `false` | `bool` | A new window started and `onExecute` already ran. |

---

#### `FastThrottle.cancel` {#fast-throttle-cancel}

Cancels the throttle window and timer for `tag`; a pending `onAfter` for that window will **not** run.

```dart
FastThrottle.cancel('checkout-submit');
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Throttle instance to cancel. |

---

#### `FastThrottle.cancelAll` {#fast-throttle-cancel-all}

Cancels **all** active throttles.

```dart
FastThrottle.cancelAll();
```

No parameters.

---

#### `FastThrottle.count` {#fast-throttle-count}

How many throttle windows are currently active.

|  | Type | Description |
| --- | --- | --- |
| Return value | `int` (getter) | Count of active throttle instances. |

---

## FastRateLimit {#fast-rate-limit}

Uses a fixed step `duration` to slice **time windows** (`Timer.periodic`). While a **rate limit is active** for a `tag`, the implementation keeps one **deferred callback** (in-window calls keep only the **latest** `onExecute` / `onAfter` you pass).

### Behavior {#fast-rate-limit-behavior}

1. **First call** (no active limiter for this `tag`): runs `onExecute` immediately and starts the window timer; returns `false`.
2. **In-window call**: does **not** run now; **replaces** the deferred callback; returns `true`.
3. **Next window boundary** (timer tick): if a deferred callback exists, runs it and its `onAfter`, then clears; if the previous window had no in-window calls, the limiter stops and may run the **`onAfter` from the first call**.

Unlike `FastThrottle`: throttle **drops** extra in-window calls; rate limit **coalesces** them into one run at the next boundary.

### Basic usage {#fast-rate-limit-example}

Infinite list: coalesce rapid “near bottom” triggers.

::: code-group

```dart [Widget]
void _onNearBottom() {
  FastRateLimit.rateLimit(
    tag: 'feed-load-more',
    duration: const Duration(milliseconds: 500),
    onExecute: () => loadNextPage(),
  );
}
```

```dart [Controller]
void onNearBottom() {
  FastRateLimit.rateLimit(
    tag: 'feed-load-more',
    duration: const Duration(milliseconds: 500),
    onExecute: () => loadNextPage(),
  );
}
```

:::

### API reference {#fast-rate-limit-api}

---

#### `FastRateLimit.rateLimit` {#fast-rate-limit-rate-limit}

**First** call runs immediately and starts fixed **time windows** of length `duration`. In-window calls defer: only the **latest** callback is kept and runs at the **next window boundary** (see [Behavior](#fast-rate-limit-behavior)).

```dart
final deferred = FastRateLimit.rateLimit(
  tag: 'feed-load-more',
  duration: const Duration(milliseconds: 500),
  onExecute: () => loadNextPage(),
  onAfter: () {}, // optional
);
// deferred == true: limiter active; merged to next window
// deferred == false: first call (or restart); onExecute already ran
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Instance id. Same `tag` shares one deferred callback and window timer. |
| `duration` | `Duration` | yes | Length of each time window (tick step). |
| `onExecute` | `void Function()` | yes | Business callback (`FastRateLimitCallback`). **Immediate** on first call; in-window calls update the **deferred** callback (latest wins at next boundary). |
| `onAfter` | `void Function()?` | no | Paired with deferred work: runs after the matching deferred `onExecute`; on idle shutdown may run the **`onAfter` from the first call**. |

| Return value | Type | Description |
| --- | --- | --- |
| `true` | `bool` | Name it `deferred`: limiter active; this call was merged; `onExecute` did **not** run now. |
| `false` | `bool` | First call or restart after idle: `onExecute` already ran and the limiter started. |

---

#### `FastRateLimit.cancel` {#fast-rate-limit-cancel}

Cancels the window timer for `tag` and removes its record; a pending **deferred** callback will not run.

```dart
FastRateLimit.cancel('feed-load-more');
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `tag` | `String` | yes | Rate limit instance to cancel. |

---

#### `FastRateLimit.cancelAll` {#fast-rate-limit-cancel-all}

Cancels **all** active rate limiters.

```dart
FastRateLimit.cancelAll();
```

No parameters.

---

#### `FastRateLimit.count` {#fast-rate-limit-count}

How many rate limiters are still active (window timer running).

|  | Type | Description |
| --- | --- | --- |
| Return value | `int` (getter) | Count of active rate limit instances. |
