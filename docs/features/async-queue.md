---
title: 异步任务队列
outline: [2, 3]
---

## 概览 {#overview}

`FastAsyncQueue` 按 **FIFO** 顺序串行执行异步任务（`AsyncJob`），适合「必须一条条做完」的场景（上传队列、串行 API、离线同步）。支持手动 `start()` 与 **自动启动** 工厂、任务 **label** 与 `JobInfo` 跟踪、失败后在任务内调用 `retry()` 的重试，以及 `QueueEvent` 监听。

| 创建方式 | 行为概要 | 典型场景 |
| --- | --- | --- |
| `FastAsyncQueue()` | 入队后不执行，需 `await start()` | 批量攒任务后统一跑 |
| `FastAsyncQueue.autoStart()` | 每次 `addJob` 后若空闲则自动 `start()` | 来一条处理一条、仍保证串行 |

---

## FastAsyncQueue {#fast-async-queue}

队列内部为链表；同一时刻 **最多一个** 任务处于 `running`。任务在 `catch` 中调用 `retry()` 可将当前任务标记为 `pendingRetry`，在本轮 `start()` 循环内再次执行；`retryTime` 为 **允许的重试次数**（默认 `1`），`-1` 表示不限次数。

### 基础使用示例 {#fast-async-queue-example}

手动启动：先 `addJob` 再 `start()`。

::: code-group

```dart [手动队列]
final queue = FastAsyncQueue();

queue.addJob(
  () => Future.delayed(const Duration(seconds: 1), () => uploadChunk(1)),
  label: 'chunk-1',
  description: '第一片',
);
queue.addJob(
  () => Future.delayed(const Duration(seconds: 1), () => uploadChunk(2)),
  label: 'chunk-2',
);

await queue.start(); // 按入队顺序串行执行
```

```dart [自动启动]
final queue = FastAsyncQueue.autoStart();

queue.addJob(() => syncProfile()); // 若队列空闲，立即开始处理
queue.addJob(() => syncSettings()); // 上一任务未完成则排队
```

```dart [失败重试]
final queue = FastAsyncQueue.autoStart();

queue.addJob(
  () async {
    try {
      await requestWithTransientError();
    } catch (_) {
      queue.retry(); // 在 retryTime 限额内再次执行当前任务
    }
  },
  label: 'sync-order',
  retryTime: 3,
);
```

:::

### 队列监听 {#fast-async-queue-events}

通过 `addQueueListener` 订阅 `QueueEvent`（含 `type`、`currentQueueSize`、`jobLabel`、发生时间）。

```dart
final queue = FastAsyncQueue();
queue.addQueueListener((event) {
  debugPrint('$event'); // QueueEvent [currentQueueSize: ..., type: ..., ...]
});
```

常见 `QueueEventType`：`queueStart` / `beforeJob` / `afterJob` / `queueEnd`、`newJobAdded`、`retryJob` / `retryLimitReached`、`queueClosed`、`queueStopped`、`violateAddWhenClosed`。

### 完整 API 参考 {#fast-async-queue-api}

---

#### 构造函数 {#fast-async-queue-constructors}

```dart
final manual = FastAsyncQueue();
final autoRun = FastAsyncQueue.autoStart();
```

|  | 说明 |
| --- | --- |
| `FastAsyncQueue()` | 普通队列；任务入队后等待 `start()`。 |
| `FastAsyncQueue.autoStart()` | 工厂；`addJob` 后若未在运行则自动调用 `start()`。 |

---

#### `FastAsyncQueue.addJob` {#fast-async-queue-add-job}

向队尾追加异步任务。队列已 `close()` 时 **静默拒绝** 并发出 `violateAddWhenClosed`；`label` 重复时抛出 `DuplicatedLabelException`。未传 `label` 时使用 ISO8601 时间字符串。

```dart
queue.addJob(
  () async => doWork(),
  label: 'job-a',
  description: '可选说明',
  retryTime: 1,
);
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `job` | `AsyncJob` | 是 | 无参、返回 `Future` 的异步函数。 |
| `label` | `String?` | 否 | 任务唯一标识；用于 `getJobInfo` 与事件中的 `jobLabel`。 |
| `description` | `String?` | 否 | 可读描述，写入 `JobInfo`。 |
| `retryTime` | `int` | 否 | 允许的重试次数，默认 `1`；`-1` 为无限重试。 |

---

#### `FastAsyncQueue.addJobThrow` {#fast-async-queue-add-job-throw}

与 `addJob` 相同，但队列已关闭时抛出 `ClosedQueueException`，便于调用方显式处理。

```dart
queue.addJobThrow(() async => doWork(), label: 'critical');
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `job` | `AsyncJob` | 是 | 要执行的任务。 |
| `label` | `String?` | 否 | 同 `addJob`。 |
| `description` | `String?` | 否 | 同 `addJob`。 |
| `retryTime` | `int` | 否 | 同 `addJob`。 |

---

#### `FastAsyncQueue.start` {#fast-async-queue-start}

若队列非空且当前未在运行，则依次执行队首任务直到队列为空、被 `stop()` 打断或循环因 `stop` 清空。队列为空、已在运行或已关闭时 **立即返回**。

```dart
await queue.start();
```

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| — | `Future<void>` | 本轮串行处理结束（或被 `stop` 终止）后完成。 |

---

#### `FastAsyncQueue.retry` {#fast-async-queue-retry}

在 **当前正在执行** 的任务体内调用（通常在 `catch` 中）。将队首任务设为 `pendingRetry`，以便在本轮 `start()` 中再次 `run()`；超过 `retryTime` 时设为 `failed` 并发出 `retryLimitReached`。

```dart
try {
  await apiCall();
} catch (_) {
  queue.retry();
}
```

无参数。

---

#### `FastAsyncQueue.stop` {#fast-async-queue-stop}

强制停止：清空待执行链表与 `_map`，重置 `size`，发出 `queueStopped`。可选 `callBack` 在停止逻辑开始时同步调用。

```dart
queue.stop(() => onQueueAborted());
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `callBack` | `Function?` | 否 | 停止时立即执行的回调。 |

---

#### `FastAsyncQueue.clear` {#fast-async-queue-clear}

内部调用 `stop(callBack)` 并清空任务映射，等价于停止并丢弃全部任务信息。

```dart
queue.clear();
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `callBack` | `Function?` | 否 | 传给 `stop` 的回调。 |

---

#### `FastAsyncQueue.close` {#fast-async-queue-close}

禁止再 `addJob`（已关闭后再加会走 `violateAddWhenClosed` 或 `ClosedQueueException`）；**已在队中或正在执行的任务会继续跑完**。发出 `queueClosed`。

```dart
queue.close();
```

无参数。

---

#### `FastAsyncQueue.addQueueListener` {#fast-async-queue-add-queue-listener}

注册单个监听器（后注册会覆盖前者），接收全部 `QueueEvent`。

```dart
queue.addQueueListener((QueueEvent event) { /* ... */ });
```

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `listener` | `QueueListener` | 是 | `void Function(QueueEvent event)`。 |

---

#### `FastAsyncQueue.getJobInfo` / `list` {#fast-async-queue-job-info}

```dart
final info = queue.getJobInfo('chunk-1');
final all = queue.list();
```

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `getJobInfo(label)` | `JobInfo` | 无此 `label` 时抛出 `InvalidJobLabelException`。 |
| `list()` | `List<JobInfo>` | 当前映射中所有任务的快照。 |

`JobInfo` 字段：`label`、`description`、`state`（`JobState`）、`retryCount`、`maxRetry`。

---

#### 属性 {#fast-async-queue-properties}

|  | 类型 | 说明 |
| --- | --- | --- |
| `size` | `int`（getter） | 待处理 + 当前执行中的任务数（链表长度）。 |
| `isClosed` | `bool`（getter） | 是否已调用 `close()`。 |

---

## 类型与异常 {#fast-async-queue-types}

### `JobState`

| 值 | 含义 |
| --- | --- |
| `pending` | 已入队，等待执行 |
| `running` | 正在执行 |
| `pendingRetry` | 已请求重试，等待再次执行 |
| `done` | 成功结束（即将出队） |
| `failed` | 失败且不再重试（即将出队） |

### 相关异常

| 类型 | 触发条件 |
| --- | --- |
| `DuplicatedLabelException` | `addJob` 使用了已存在的 `label` |
| `ClosedQueueException` | 对已关闭队列调用 `addJobThrow` |
| `InvalidJobLabelException` | `getJobInfo` 找不到 `label` |
