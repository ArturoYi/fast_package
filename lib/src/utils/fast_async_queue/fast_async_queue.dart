import 'enum.dart';
import 'exceptions.dart';
import 'fast_queue_event.dart';
import 'fast_async_node.dart';
import 'fast_job_info.dart';
import 'typedef.dart';
import 'interfaces.dart';

/// A queue implementation for managing and executing asynchronous tasks in a sequential manner.
/// This queue supports features like automatic execution, retry mechanism, and event listening.
/// 
/// Key features:
/// - Sequential execution of async tasks
/// - Auto-start mode for immediate execution
/// - Retry mechanism for failed tasks
/// - Event listening for queue state changes
/// - Task labeling and status tracking
/// 
/// 异步队列的实现，用于管理和按顺序执行异步任务。
/// 该队列支持自动执行、重试机制和事件监听等功能。
/// 
/// 主要特性：
/// - 按顺序执行异步任务
/// - 自动启动模式，支持立即执行
/// - 失败任务的重试机制
/// - 队列状态变化的事件监听
/// - 任务标签和状态跟踪
class FastAsyncQueue extends AsyncQueueInterface {
  FastAsyncNode? _first;
  FastAsyncNode? _last;
  int _size = 0;
  bool _autoRun = false;
  bool _isRunning = false;
  QueueListener? _listener;
  bool _isClosed = false;
  bool _isForcedClosed = false;
  final Map<String, JobInfo> _map = {};

  /// Initialize a normal queue that requires manual start.
  /// Tasks will be queued but won't execute until [start()] is called.
  /// 
  /// 初始化普通队列。
  /// 任务会被加入队列，但需要调用 [start()] 才会开始执行。
  ///
  /// which require user to explicitly call [start()]
  /// in order to execute all the jobs in the queue
  FastAsyncQueue();

  /// Initialize an auto-start queue that begins processing tasks immediately when added.
  /// If there's already a task running, new tasks will wait in the queue.
  /// 
  /// 初始化自动启动队列，添加任务后会立即开始处理。
  /// 如果已有任务在运行，新任务会在队列中等待。
  ///
  /// which will execute the job when it added into the queue
  /// if there is an executing job, the new will have to wait for its turn
  factory FastAsyncQueue.autoStart() => FastAsyncQueue().._autoRun = true;

  /// Add a listener to monitor queue events.
  /// The listener will receive events for all queue state changes including:
  /// - Task addition/completion
  /// - Queue start/stop
  /// - Retry attempts
  /// - Queue closure
  /// 
  /// 添加监听器以监控队列事件。
  /// 监听器会接收所有队列状态变化的事件，包括：
  /// - 任务添加/完成
  /// - 队列启动/停止
  /// - 重试尝试
  /// - 队列关闭
  void addQueueListener(QueueListener listener) => _listener = listener;

  /// Get the current number of tasks in the queue.
  /// This includes both pending and currently executing tasks.
  /// 
  /// 获取队列中当前的任务数量。
  /// 包括等待中和正在执行的任务。
  ///
  /// equal to number of jobs that left in the queue
  int get size => _size;

  /// Check if the queue is closed.
  /// When closed, no new tasks can be added, but existing tasks will continue to execute.
  /// 
  /// 检查队列是否已关闭。
  /// 关闭后不能添加新任务，但现有任务会继续执行。
  bool get isClosed => _isClosed;

  /// Add a new asynchronous task to the queue.
  /// 
  /// Parameters:
  /// - [job]: The async function to be executed
  /// - [label]: Optional unique identifier for the task
  /// - [description]: Optional description of the task
  /// - [retryTime]: Number of retry attempts if the task fails (default: 1)
  /// 
  /// If the queue is closed, the task will be rejected silently.
  /// If a label is provided and already exists, throws [DuplicatedLabelException].
  /// 
  /// 向队列添加新的异步任务。
  /// 
  /// 参数：
  /// - [job]: 要执行的异步函数
  /// - [label]: 可选的任务唯一标识符
  /// - [description]: 可选的任务描述
  /// - [retryTime]: 任务失败时的重试次数（默认：1）
  /// 
  /// 如果队列已关闭，任务会被静默拒绝。
  /// 如果提供的标签已存在，会抛出 [DuplicatedLabelException] 异常。
  @override
  void addJob(
    AsyncJob job, {
    String? label,
    String? description,
    int retryTime = 1,
  }) {
    if (isClosed) {
      return _emitEvent(QueueEventType.violateAddWhenClosed);
    }
    if (label != null && _map.containsKey(label)) {
      throw DuplicatedLabelException("A job with this label already exists");
    }
    final newNode = FastAsyncNode(
      job: job,
      maxRetry: retryTime,
      label: label ?? DateTime.now().toIso8601String(),
      description: description,
    );
    _map[newNode.label] = newNode.info;
    _enqueue(newNode);
    if (_autoRun) start();
  }

  /// Add a new task to the queue with strict error handling.
  /// 
  /// Similar to [addJob], but throws [ClosedQueueException] if the queue is closed
  /// instead of silently rejecting the task.
  /// 
  /// This method is useful when you need to ensure the task is actually added
  /// to the queue or handle the failure explicitly.
  /// 
  /// 向队列添加新任务，使用严格的错误处理。
  /// 
  /// 与 [addJob] 类似，但在队列关闭时会抛出 [ClosedQueueException] 异常，
  /// 而不是静默拒绝任务。
  /// 
  /// 当你需要确保任务确实被添加到队列中或者要显式处理失败情况时，
  /// 这个方法很有用。
  @override
  void addJobThrow(
    AsyncJob job, {
    String? label,
    String? description,
    int retryTime = 1,
  }) {
    if (isClosed) {
      throw ClosedQueueException("Closed Queue");
    } else {
      addJob(
        job,
        retryTime: retryTime,
        label: label,
        description: description,
      );
    }
  }

  /// Clear all tasks from the queue and stop processing.
  /// 
  /// Parameters:
  /// - [callBack]: Optional function to be called after clearing the queue
  /// 
  /// This method stops the queue processing and removes all pending tasks.
  /// The callback is executed after the queue is cleared.
  /// 
  /// 清空队列中的所有任务并停止处理。
  /// 
  /// 参数：
  /// - [callBack]: 清空队列后可选的回调函数
  /// 
  /// 此方法会停止队列处理并移除所有待处理的任务。
  /// 回调函数会在队列清空后执行。
  @override
  void clear([Function? callBack]) {
    stop(callBack);
    _map.clear();
  }

  /// Close the queue to prevent adding new tasks.
  /// 
  /// After closing:
  /// - No new tasks can be added
  /// - Existing tasks continue to execute
  /// - Queue state changes to closed
  /// - Emits a queueClosed event
  /// 
  /// 关闭队列以防止添加新任务。
  /// 
  /// 关闭后：
  /// - 不能添加新任务
  /// - 现有任务继续执行
  /// - 队列状态变为已关闭
  /// - 发出队列关闭事件
  @override
  void close() {
    _isClosed = true;
    _emitEvent(QueueEventType.queueClosed);
  }

  /// Get information about a specific task by its label.
  /// 
  /// Parameters:
  /// - [label]: The unique identifier of the task
  /// 
  /// Returns a [JobInfo] object containing the task's current state,
  /// retry count, and other details.
  /// 
  /// Throws [InvalidJobLabelException] if no task with the given label exists.
  /// 
  /// 通过标签获取特定任务的信息。
  /// 
  /// 参数：
  /// - [label]: 任务的唯一标识符
  /// 
  /// 返回包含任务当前状态、重试次数等详细信息的 [JobInfo] 对象。
  /// 
  /// 如果找不到指定标签的任务，会抛出 [InvalidJobLabelException] 异常。
  @override
  JobInfo getJobInfo(String label) {
    if (!_map.containsKey(label)) {
      throw InvalidJobLabelException("No job with this label found");
    }
    return _map[label]!;
  }

  /// Get a list of all tasks in the queue.
  /// 
  /// Returns a list of [JobInfo] objects containing information about all tasks,
  /// including their current state, retry count, and other details.
  /// 
  /// This method is useful for monitoring the queue's state and debugging.
  /// 
  /// 获取队列中所有任务的列表。
  /// 
  /// 返回包含所有任务信息的 [JobInfo] 对象列表，
  /// 包括它们的当前状态、重试次数等详细信息。
  /// 
  /// 此方法对于监控队列状态和调试很有用。
  @override
  List<JobInfo> list() {
    return _map.values.toList();
  }

  /// Retry the current task if it has failed.
  /// 
  /// Behavior:
  /// - If maxRetry is -1, allows infinite retries
  /// - If retry count exceeds maxRetry, marks task as failed
  /// - Updates retry count and sets state to pendingRetry
  /// - Emits appropriate events (retryJob or retryLimitReached)
  /// 
  /// 重试当前失败的任务。
  /// 
  /// 行为：
  /// - 如果 maxRetry 为 -1，允许无限重试
  /// - 如果重试次数超过 maxRetry，将任务标记为失败
  /// - 更新重试计数并将状态设置为等待重试
  /// - 发出相应的事件（重试任务或达到重试限制）
  @override
  void retry() {
    if (_first?.maxRetry == -1) {
      _first?.state = JobState.pendingRetry;
      _updateQueueMap(_first?.info);
      return;
    }
    if ((_first?.retryCount ?? 0) >= (_first?.maxRetry ?? 0)) {
      _emitEvent(QueueEventType.retryLimitReached, _first?.label);
      _first?.state = JobState.failed;
      _updateQueueMap(_first?.info);
      return;
    }
    _first?.retryCount++;
    _first?.state = JobState.pendingRetry;
    _updateQueueMap(_first?.info);
  }

  /// Start processing tasks in the queue.
  /// 
  /// This method:
  /// - Starts executing tasks if queue is not empty and not already running
  /// - Processes tasks sequentially until queue is empty or stopped
  /// - Emits events for queue start, task execution, and queue end
  /// - Handles task retries automatically
  /// 
  /// Returns immediately if:
  /// - Queue is empty
  /// - Queue is already running
  /// - Queue is closed
  /// 
  /// 开始处理队列中的任务。
  /// 
  /// 此方法：
  /// - 如果队列不为空且未在运行，开始执行任务
  /// - 按顺序处理任务，直到队列为空或被停止
  /// - 发出队列启动、任务执行和队列结束的事件
  /// - 自动处理任务重试
  /// 
  /// 在以下情况下立即返回：
  /// - 队列为空
  /// - 队列已在运行
  /// - 队列已关闭
  @override
  Future<void> start() async {
    if (size == 0 || _isRunning) return;

    _isRunning = true;
    _emitEvent(QueueEventType.queueStart);

    while (size > 0) {
      if (_isForcedClosed) break;
      await _dequeue();
    }

    _isRunning = false;
    _emitEvent(QueueEventType.queueEnd);
  }

  /// Stop the queue and clear all tasks.
  /// 
  /// Parameters:
  /// - [callBack]: Optional function to be called after stopping the queue
  /// 
  /// This method:
  /// - Forces the queue to stop processing
  /// - Clears all pending tasks
  /// - Resets queue state
  /// - Executes callback if provided
  /// - Emits queueStopped event
  /// 
  /// 停止队列并清除所有任务。
  /// 
  /// 参数：
  /// - [callBack]: 停止队列后可选的回调函数
  /// 
  /// 此方法：
  /// - 强制停止队列处理
  /// - 清除所有待处理的任务
  /// - 重置队列状态
  /// - 执行回调函数（如果提供）
  /// - 发出队列停止事件
  @override
  void stop([Function? callBack]) {
    if (callBack != null) callBack.call();
    _isForcedClosed = true;
    _isRunning = false;
    _first = null;
    _last = null;
    _size = 0;
    _map.clear();
    _emitEvent(QueueEventType.queueStopped);
  }

  /// Remove and execute the first task in the queue.
  /// 
  /// This internal method:
  /// - Gets the first task from the queue
  /// - Emits beforeJob event
  /// - Updates task state to running
  /// - Executes the task
  /// - Handles task completion or failure
  /// - Updates queue state and size
  /// - Emits appropriate events (afterJob or retryJob)
  /// 
  /// Special handling:
  /// - Returns immediately if queue is empty
  /// - Handles stop requests during execution
  /// - Updates task state based on execution result
  /// 
  /// 移除并执行队列中的第一个任务。
  /// 
  /// 这个内部方法：
  /// - 获取队列中的第一个任务
  /// - 发出任务开始事件
  /// - 更新任务状态为运行中
  /// - 执行任务
  /// - 处理任务完成或失败
  /// - 更新队列状态和大小
  /// - 发出相应的事件（任务完成或重试）
  /// 
  /// 特殊处理：
  /// - 如果队列为空则立即返回
  /// - 处理执行过程中的停止请求
  /// - 根据执行结果更新任务状态
  Future _dequeue() async {
    if (_first == null) return;
    final jobLabel = _first?.label;
    var currentNode = _first;
    _emitEvent(QueueEventType.beforeJob, jobLabel);
    _updateQueueMap(
      _first?.info.copyWith(state: JobState.running),
    );
    await _first?.run();

    //incase [stop] is called
    if (_first == null) return;

    if (_first?.state == JobState.running) {
      _first?.state = JobState.done;
    }

    if (_first?.state == JobState.done || _first?.state == JobState.failed) {
      _updateQueueMap(_first?.info);
      if (size == 1) {
        _first = null;
        _last = null;
      } else {
        _first = currentNode?.next;
        currentNode?.next = null;
      }
      _size--;
      _emitEvent(QueueEventType.afterJob, jobLabel);
    } else {
      _emitEvent(QueueEventType.retryJob, jobLabel);
    }
  }

  /// Update the task information in the queue's map.
  /// 
  /// Parameters:
  /// - [info]: The updated JobInfo object
  /// 
  /// This internal method updates the stored information for a task
  /// if it exists in the queue's map. Used to keep track of task state changes.
  /// 
  /// 更新队列映射中的任务信息。
  /// 
  /// 参数：
  /// - [info]: 更新后的 JobInfo 对象
  /// 
  /// 这个内部方法在任务存在于队列映射中时更新其存储的信息。
  /// 用于跟踪任务状态的变化。
  void _updateQueueMap(
    JobInfo? info,
  ) {
    if (info != null && _map.containsKey(info.label)) {
      _map.update(info.label, (value) => info);
    }
  }

  /// Add a new task node to the queue.
  /// 
  /// Parameters:
  /// - [node]: The AsyncNode to be added
  /// 
  /// This internal method:
  /// - Handles empty queue case
  /// - Updates queue pointers (_first and _last)
  /// - Increments queue size
  /// - Emits newJobAdded event
  /// 
  /// 将新的任务节点添加到队列中。
  /// 
  /// 参数：
  /// - [node]: 要添加的 AsyncNode
  /// 
  /// 这个内部方法：
  /// - 处理队列为空的情况
  /// - 更新队列指针（_first 和 _last）
  /// - 增加队列大小
  /// - 发出新任务添加事件
  void _enqueue(FastAsyncNode node) {
    if (_first == null) {
      _first = node;
      _last = node;
    } else {
      _last?.next = node;
      _last = node;
    }
    _size++;

    _emitEvent(QueueEventType.newJobAdded, _first?.label);
  }

  /// Emit a queue event to the registered listener.
  /// 
  /// Parameters:
  /// - [type]: The type of queue event
  /// - [label]: Optional label of the task related to the event
  /// 
  /// This internal method creates and emits a QueueEvent to the registered
  /// listener if one exists. The event includes the current queue size,
  /// event type, and optional task label.
  /// 
  /// 向注册的监听器发出队列事件。
  /// 
  /// 参数：
  /// - [type]: 队列事件的类型
  /// - [label]: 可选的相关任务标签
  /// 
  /// 这个内部方法创建并向注册的监听器（如果存在）发出 QueueEvent。
  /// 事件包含当前队列大小、事件类型和可选的任务标签。
  void _emitEvent(QueueEventType type, [String? label]) {
    if (_listener != null) {
      _listener!(QueueEvent(
        currentQueueSize: _size,
        type: type,
        jobLabel: label,
      ));
    }
  }
}
