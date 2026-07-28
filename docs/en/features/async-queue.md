---
title: Async Task Queue
outline: [2, 3]
---

## Overview {#overview}

`FastAsyncQueue` runs async jobs (`AsyncJob`) **serially in FIFO order**—upload queues, sequential APIs, offline sync, etc. Supports manual `start()` vs **auto-start** factory, **label** + `JobInfo` tracking, in-task `retry()` with a retry budget, and `QueueEvent` listeners.

| Factory | Behavior | Typical use |
| --- | --- | --- |
| `FastAsyncQueue()` | Jobs wait until `await start()` | Batch enqueue, run once |
| `FastAsyncQueue.autoStart()` | `addJob` starts processing when idle | Process on arrival, still serial |

---

## FastAsyncQueue {#fast-async-queue}

Internal linked list; **at most one** job is `running`. Calling `retry()` inside `catch` marks the head job `pendingRetry` for another run in the same `start()` loop. `retryTime` is the **allowed retry count** (default `1`); `-1` means unlimited.

### Examples {#fast-async-queue-example}

Manual: enqueue then `start()`.

::: code-group

```dart [Manual queue]
final queue = FastAsyncQueue();

queue.addJob(
  () => Future.delayed(const Duration(seconds: 1), () => uploadChunk(1)),
  label: 'chunk-1',
  description: 'First chunk',
);
queue.addJob(
  () => Future.delayed(const Duration(seconds: 1), () => uploadChunk(2)),
  label: 'chunk-2',
);

await queue.start(); // FIFO
```

```dart [Auto-start]
final queue = FastAsyncQueue.autoStart();

queue.addJob(() => syncProfile());  // runs if idle
queue.addJob(() => syncSettings()); // waits if busy
```

```dart [Retry on failure]
final queue = FastAsyncQueue.autoStart();

queue.addJob(
  () async {
    try {
      await requestWithTransientError();
    } catch (_) {
      queue.retry(); // within retryTime budget
    }
  },
  label: 'sync-order',
  retryTime: 3,
);
```

:::

### Queue events {#fast-async-queue-events}

Subscribe with `addQueueListener` for `QueueEvent` (`type`, `currentQueueSize`, `jobLabel`, timestamp).

```dart
final queue = FastAsyncQueue();
queue.addQueueListener((event) {
  debugPrint('$event');
});
```

Common `QueueEventType`: `queueStart` / `beforeJob` / `afterJob` / `queueEnd`, `newJobAdded`, `retryJob` / `retryLimitReached`, `queueClosed`, `queueStopped`, `violateAddWhenClosed`.

### API reference {#fast-async-queue-api}

---

#### Constructors {#fast-async-queue-constructors}

```dart
final manual = FastAsyncQueue();
final autoRun = FastAsyncQueue.autoStart();
```

|  | Description |
| --- | --- |
| `FastAsyncQueue()` | Jobs wait for `start()`. |
| `FastAsyncQueue.autoStart()` | Calls `start()` after `addJob` when not already running. |

---

#### `FastAsyncQueue.addJob` {#fast-async-queue-add-job}

Appends a job. After `close()`, **silently rejects** and emits `violateAddWhenClosed`; duplicate `label` throws `DuplicatedLabelException`. Default `label` is an ISO8601 timestamp.

```dart
queue.addJob(
  () async => doWork(),
  label: 'job-a',
  description: 'Optional note',
  retryTime: 1,
);
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `job` | `AsyncJob` | yes | Nullary function returning `Future`. |
| `label` | `String?` | no | Unique id for `getJobInfo` and events. |
| `description` | `String?` | no | Stored on `JobInfo`. |
| `retryTime` | `int` | no | Retry budget, default `1`; `-1` = unlimited. |

---

#### `FastAsyncQueue.addJobThrow` {#fast-async-queue-add-job-throw}

Same as `addJob`, but throws `ClosedQueueException` when the queue is closed.

```dart
queue.addJobThrow(() async => doWork(), label: 'critical');
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `job` | `AsyncJob` | yes | Task to run. |
| `label` | `String?` | no | Same as `addJob`. |
| `description` | `String?` | no | Same as `addJob`. |
| `retryTime` | `int` | no | Same as `addJob`. |

---

#### `FastAsyncQueue.start` {#fast-async-queue-start}

When non-empty and not already running, drains the queue until empty, `stop()` interrupts, or the loop clears on stop. No-op when empty, already running, or closed.

```dart
await queue.start();
```

| Return | Type | Description |
| --- | --- | --- |
| — | `Future<void>` | Completes when this run finishes (or is stopped). |

---

#### `FastAsyncQueue.retry` {#fast-async-queue-retry}

Call **inside the running job** (usually in `catch`). Marks the head job `pendingRetry` for another `run()` in this `start()` loop; exceeds `retryTime` → `failed` and `retryLimitReached`.

```dart
try {
  await apiCall();
} catch (_) {
  queue.retry();
}
```

No parameters.

---

#### `FastAsyncQueue.stop` {#fast-async-queue-stop}

Hard stop: clears pending list and `_map`, resets `size`, emits `queueStopped`. Optional `callBack` runs synchronously at the start.

```dart
queue.stop(() => onQueueAborted());
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `callBack` | `Function?` | no | Runs when stop begins. |

---

#### `FastAsyncQueue.clear` {#fast-async-queue-clear}

Calls `stop(callBack)` and clears job metadata.

```dart
queue.clear();
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `callBack` | `Function?` | no | Passed to `stop`. |

---

#### `FastAsyncQueue.close` {#fast-async-queue-close}

Blocks further `addJob` (`violateAddWhenClosed` or `ClosedQueueException`); **queued and running jobs still finish**. Emits `queueClosed`.

```dart
queue.close();
```

No parameters.

---

#### `FastAsyncQueue.addQueueListener` {#fast-async-queue-add-queue-listener}

Registers one listener (later registration replaces the previous). Receives all `QueueEvent`s.

```dart
queue.addQueueListener((QueueEvent event) { /* ... */ });
```

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `listener` | `QueueListener` | yes | `void Function(QueueEvent event)`. |

---

#### `FastAsyncQueue.getJobInfo` / `list` {#fast-async-queue-job-info}

```dart
final info = queue.getJobInfo('chunk-1');
final all = queue.list();
```

| Method | Return | Description |
| --- | --- | --- |
| `getJobInfo(label)` | `JobInfo` | Throws `InvalidJobLabelException` if missing. |
| `list()` | `List<JobInfo>` | Snapshot of all tracked jobs. |

`JobInfo`: `label`, `description`, `state` (`JobState`), `retryCount`, `maxRetry`.

---

#### Properties {#fast-async-queue-properties}

|  | Type | Description |
| --- | --- | --- |
| `size` | `int` (getter) | Pending + running count (list length). |
| `isClosed` | `bool` (getter) | Whether `close()` was called. |

---

## Types and exceptions {#fast-async-queue-types}

### `JobState`

| Value | Meaning |
| --- | --- |
| `pending` | Enqueued, waiting |
| `running` | Executing |
| `pendingRetry` | Retry requested |
| `done` | Success (about to dequeue) |
| `failed` | Failed, no more retries (about to dequeue) |

### Exceptions

| Type | When |
| --- | --- |
| `DuplicatedLabelException` | Duplicate `label` on `addJob` |
| `ClosedQueueException` | `addJobThrow` on closed queue |
| `InvalidJobLabelException` | Unknown `label` in `getJobInfo` |
