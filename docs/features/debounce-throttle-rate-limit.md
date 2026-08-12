---
title: 防抖、节流、速率限制
outline: [2, 3]
---

<p class="doc-source">
  <span>GitHub 源码</span>
  <span aria-hidden="true">·</span>
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/utils/fast_debounce" target="_blank" rel="noreferrer"><code>fast_debounce/</code></a>
  <span aria-hidden="true">·</span>
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/utils/fast_throttle" target="_blank" rel="noreferrer"><code>fast_throttle/</code></a>
  <span aria-hidden="true">·</span>
  <a href="https://github.com/ArturoYi/fast_package/tree/master/lib/src/utils/fast_rate_limit" target="_blank" rel="noreferrer"><code>fast_rate_limit/</code></a>
</p>

## 概览 {#overview}

基于 `dart:async` `Timer` 的静态工具类，用于控制高频触发的副作用（如按钮连点、搜索框输入、滚动回调）。三者均通过 `tag` 区分不同业务场景，互不干扰。

| 工具            | 行为概要                                                                                                                         | 典型场景                     |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `FastDebounce`  | 连续触发时不断推迟；**静默期**结束后只跑**最后一次**                                                                             | 搜索联想、窗口 resize        |
| `FastThrottle`  | 每个**节流窗口**内**至多执行一次**（窗口首调立即执行，窗内其余调用**丢弃**）                                                     | 提交按钮、点赞               |
| `FastRateLimit` | **首调**立即执行并开启按 `duration` 划分的**时间窗**；窗内再调**不立刻执行**，只**合并**为一份**延后回调**，在**下一窗起点**补跑 | 搜索词合并提交、滚动分页加载 |

---

## FastDebounce {#fast-debounce}

`FastDebounce` 在每次调用时**重置**静默计时器；仅在连续 `duration` 内没有新调用时，才执行 `onExecute`。`duration` 为 `Duration.zero` 时立即执行并清理已有计时器。

### 基础使用示例 {#fast-debounce-example}

搜索框：停输后再请求，避免每个字符都调接口。

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

// 页面销毁时取消未完成的防抖
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

### 完整 API 参考 {#fast-debounce-api}

---

#### `FastDebounce.debounce` {#fast-debounce-debounce}

连续触发时不断推迟执行，只在静默期结束时运行**最后一次**传入的 `onExecute`。

```dart
FastDebounce.debounce(
  tag: 'search-suggest',
  duration: const Duration(milliseconds: 300),
  onExecute: () {
    // 静默期结束后执行
  },
);
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 防抖实例标识。相同 `tag` 共用一条计时链；不同业务请分开命名（如 `'search-suggest'`）。 |
| `duration` | `Duration` | 是 | 静默等待时长。每次再调都会**重置**计时；连续 `duration` 内无新调用才执行 `onExecute`。为 `Duration.zero` 时**立即**执行并清掉已有计时器。 |
| `onExecute` | `void Function()` | 是 | 静默期结束后执行的副作用（typedef：`FastDebounceVoidCallback`）。 |

---

#### `FastDebounce.fire` {#fast-debounce-fire}

不等静默期结束，**立刻**执行当前为该 `tag` 缓存的 `onExecute`（例如用户点「立即搜索」）。  
`fire` **不会**关闭已为该 `tag` 安排的静默计时器：若之后不再有新的 `debounce` 调用，静默期仍会到期，`onExecute` 会**再执行一次**。若你希望「只立刻跑这一次、静默到期时不要再跑」，请在同 `tag` 上先 `fire`、再 `cancel`。

```dart
FastDebounce.fire('search-suggest');

// 只立刻执行，且避免静默到期后再执行一次：
FastDebounce.fire('search-suggest');
FastDebounce.cancel('search-suggest');
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 要立刻执行的防抖实例标识。 |

---

#### `FastDebounce.cancel` {#fast-debounce-cancel}

取消指定 `tag` 的计时器并移除内部记录；尚未触发的 `onExecute` **不会再执行**。页面 `dispose` 时建议调用，避免泄漏或离页后仍回调。

```dart
FastDebounce.cancel('search-suggest');
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 要取消的防抖实例标识。 |

---

#### `FastDebounce.cancelAll` {#fast-debounce-cancel-all}

一次性取消**所有**进行中的防抖（例如全局登出、重置应用状态时）。

```dart
FastDebounce.cancelAll();
```

无参数。

---

#### `FastDebounce.count` {#fast-debounce-count}

查询当前仍处在「等待静默期」的防抖数量，便于调试或监控。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `int`（getter） | 仍在计时中的防抖实例个数。 |

---

## FastThrottle {#fast-throttle}

`FastThrottle` 为同一 `tag` 维护一个**节流窗口**（长度 `duration`）。窗口的**首调**立即执行 `onExecute`；窗口内的后续调用**不会执行**（返回值 `skipped == true`）。窗口结束后可选执行 `onAfter`。

### 基础使用示例 {#fast-throttle-example}

提交按钮：连点只触发一次下单。

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
  child: const Text('确认下单'),
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

### 完整 API 参考 {#fast-throttle-api}

---

#### `FastThrottle.throttle` {#fast-throttle-throttle}

为同一 `tag` 维护一个固定长度的**节流窗口**：窗口**首调**立刻执行 `onExecute`，窗内重复调用直接丢弃。

```dart
final skipped = FastThrottle.throttle(
  tag: 'checkout-submit',
  duration: const Duration(seconds: 1),
  onExecute: () => placeOrder(),
  onAfter: () {}, // 可选
);
// skipped == true：仍在节流窗口内，本次被丢弃
// skipped == false：新窗口已开始，并已执行 onExecute
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 节流实例标识。同一 `tag` 在同一时刻最多只有一个活跃窗口。 |
| `duration` | `Duration` | 是 | 节流窗口长度。窗内再次调用**不会**延长窗口，只会被忽略。 |
| `onExecute` | `void Function()` | 是 | 进入新窗口时的**首调**回调，会**立即**执行（typedef：`FastThrottleVoidCallback`）。 |
| `onAfter` | `void Function()?` | 否 | 窗口结束（计时器到期）时执行；例如恢复按钮可点状态。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| `true` | `bool` | 建议命名为 `skipped`：本次落在已有窗口内，**未**执行 `onExecute`。 |
| `false` | `bool` | 刚开启新窗口，并已立刻执行 `onExecute`。 |

---

#### `FastThrottle.cancel` {#fast-throttle-cancel}

取消指定 `tag` 的节流窗口与计时器；该窗口内尚未触发的 `onAfter` 也**不会再**执行。

```dart
FastThrottle.cancel('checkout-submit');
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 要取消的节流实例标识。 |

---

#### `FastThrottle.cancelAll` {#fast-throttle-cancel-all}

取消**全部**进行中的节流。

```dart
FastThrottle.cancelAll();
```

无参数。

---

#### `FastThrottle.count` {#fast-throttle-count}

查询当前仍处于活跃节流窗口内的实例数量。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `int`（getter） | 进行中的节流实例个数。 |

---

## FastRateLimit {#fast-rate-limit}

`FastRateLimit` 用固定步长 `duration` 划分**时间窗**（内部为 `Timer.periodic`）。同一 `tag` 在**限流进行中**时，会维护一份 **延后回调**（窗内多次调用只保留**最后一次**传入的 `onExecute` / `onAfter`）。

### 行为说明 {#fast-rate-limit-behavior}

1. **首调**（该 `tag` 当前没有进行中的限流）：立刻执行本次 `onExecute`，并启动按 `duration` 划窗的定时器；返回 `false`。
2. **窗内再调**：**不**立刻执行；用本次传入的回调**替换**延后回调；返回 `true`。
3. **下一窗起点**（定时器触发）：若存在延后回调，则执行它及其 `onAfter`，然后清空；若上一个时间窗内没有任何「窗内再调」，则结束限流，并可能执行**首调时**传入的 `onAfter`。

与 `FastThrottle` 的区别：节流在窗内**丢弃**多余调用；速率限制在窗内**合并**为「下一窗起点执行最新一次逻辑」。

### 基础使用示例 {#fast-rate-limit-example}

列表触底：合并短时间内的多次加载请求。

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

### 完整 API 参考 {#fast-rate-limit-api}

---

#### `FastRateLimit.rateLimit` {#fast-rate-limit-rate-limit}

**首调**立刻执行并开启按 `duration` 划分的时间窗；窗内再调不立刻跑，只把最新一次回调存为**延后回调**，在**下一窗起点**补跑（详见上文 [行为说明](#fast-rate-limit-behavior)）。

```dart
final deferred = FastRateLimit.rateLimit(
  tag: 'feed-load-more',
  duration: const Duration(milliseconds: 500),
  onExecute: () => loadNextPage(),
  onAfter: () {}, // 可选
);
// deferred == true：限流进行中，本次已合并到下一窗
// deferred == false：首调（或限流结束后的重新开始），已立刻执行 onExecute
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 限流实例标识。相同 `tag` 共享同一份延后回调与划窗定时器。 |
| `duration` | `Duration` | 是 | 每个时间窗的长度（划窗步长）。 |
| `onExecute` | `void Function()` | 是 | 业务回调（typedef：`FastRateLimitCallback`）。**首调**时立即执行；**窗内再调**时只更新延后回调，在下一窗起点执行**最后一次**写入的版本。 |
| `onAfter` | `void Function()?` | 否 | 与延后回调配对：对应 `onExecute` 跑完后调用**同一次**传入的 `onAfter`；若整窗无再调导致限流结束，可能执行**首调时**传入的 `onAfter`。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| `true` | `bool` | 建议命名为 `deferred`：限流仍在进行，本次已合并到下一窗，**未**立刻执行 `onExecute`。 |
| `false` | `bool` | 首调或限流已结束后的重新开始：已立刻执行 `onExecute` 并开启限流。 |

---

#### `FastRateLimit.cancel` {#fast-rate-limit-cancel}

取消指定 `tag` 的划窗定时器并移除记录；尚未在下一窗执行的**延后回调**不会再跑。

```dart
FastRateLimit.cancel('feed-load-more');
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `tag` | `String` | 是 | 要取消的限流实例标识。 |

---

#### `FastRateLimit.cancelAll` {#fast-rate-limit-cancel-all}

取消**全部**进行中的速率限制。

```dart
FastRateLimit.cancelAll();
```

无参数。

---

#### `FastRateLimit.count` {#fast-rate-limit-count}

查询当前仍在限流进行中（划窗定时器仍在运行）的实例数量。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `int`（getter） | 进行中的限流实例个数。 |
