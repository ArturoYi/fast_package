---
title: Async Task Queue
---

### Async Task Queue

A queue for managing and running asynchronous tasks in order.

#### Key features

- ✅ Run async tasks sequentially
- ✅ Auto-start mode
- ✅ Configurable task retries
- ✅ Listen for queue state changes
- ✅ Task tags and status tracking

#### Basic usage — create a queue

```dart
// Standard queue; call start() manually
final asyncQ = AsyncQueue();
asyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 1), () => print("normalQ: 1")));
asyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 4), () => print("normalQ: 2")));
asyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 2), () => print("normalQ: 3")));
asyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 1), () => print("normalQ: 4")));

await asyncQ.start();

// Output:
// normalQ: 1
// normalQ: 2
// normalQ: 3
// normalQ: 4
```

#### Auto-start queue

```dart
// Auto-start queue; jobs run as soon as they are added
final autoAsyncQ = AsyncQueue.autoStart();

autoAsyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 1), () => print("AutoQ: 1")));
await Future.delayed(const Duration(seconds: 6));
autoAsyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 0), () => print("AutoQ: 1.2")));
autoAsyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 0), () => print("AutoQ: 1.3")));
autoAsyncQ.addJob(() =>
    Future.delayed(const Duration(seconds: 4), () => print("AutoQ: 2")));

// Output:
// AutoQ: 1
// AutoQ: 1.2
// AutoQ: 1.3
// AutoQ: 2
```

#### Queue listeners

```dart
final asyncQ = AsyncQueue();
asyncQ.addQueueListener((event) => print("$event"));
```

#### Retry on failure

```dart
q.addJob(() async {
  try {
    // do something
  } catch (e) {
    q.retry();
  }
},
// default is 1
retryTime: 3,
);
```
