---
title: Async Task Queue
---

### Async Task Queue

A queue implementation for managing and executing asynchronous tasks in sequence.

#### Key Features

- ✅ Sequential execution of async tasks
- ✅ Auto-start mode
- ✅ Configurable task retry mechanism
- ✅ Event listening for queue state changes
- ✅ Task labeling and status tracking

#### Basic Usage - Create Queue

```dart
// Normal queue, requires manual start() call
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

#### Auto-Execute Queue

```dart
// Auto-start queue, executes immediately after adding tasks
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

#### Queue Monitoring

```dart
final asyncQ = AsyncQueue();
asyncQ.addQueueListener((event) => print("$event"));
```

#### Queue Failure Retry

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
