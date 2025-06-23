/// States of a job in the async queue.
/// Represents the different states that a job can be in during its lifecycle in the queue.
/// 
/// 异步队列中任务的状态。
/// 表示任务在队列生命周期中可能处于的不同状态。
enum JobState {
  /// Job is waiting to be executed.
  /// 任务正在等待执行。
  pending,

  /// Job is currently being executed.
  /// 任务当前正在执行。
  running,

  /// Job has failed and has been removed from the queue.
  /// 任务已失败并已从队列中移除。
  failed,

  /// Job has completed successfully and has been removed from the queue.
  /// 任务已成功完成并已从队列中移除。
  done,

  /// Job has failed but is waiting to be retried.
  /// 任务已失败但正在等待重试。
  pendingRetry,
}


/// Types of events that can be emitted by the async queue.
/// These events allow listeners to monitor and respond to changes in the queue's state.
/// 
/// 异步队列可以发出的事件类型。
/// 这些事件允许监听器监控并响应队列状态的变化。
enum QueueEventType {
  /// Emitted when the queue starts processing jobs.
  /// 当队列开始处理任务时发出。
  queueStart,

  /// Emitted before a job is executed.
  /// 在执行任务之前发出。
  beforeJob,

  /// Emitted after a job has been executed.
  /// 在执行任务之后发出。
  afterJob,

  /// Emitted when the queue finishes processing all jobs.
  /// 当队列完成处理所有任务时发出。
  queueEnd,

  /// Emitted when a new job is added to the queue.
  /// 当新任务添加到队列时发出。
  newJobAdded,

  /// Emitted when the queue is closed and will not accept new jobs.
  /// 当队列关闭且不再接受新任务时发出。
  queueClosed,

  /// Emitted when the queue is manually stopped.
  /// 当队列被手动停止时发出。
  queueStopped,

  /// Emitted when an attempt is made to add a new job to a closed queue.
  /// 当尝试向已关闭的队列添加新任务时发出。
  violateAddWhenClosed,

  /// Emitted when a job is being retried after a failure.
  /// 当任务在失败后被重试时发出。
  retryJob,

  /// Emitted when a job has reached its maximum retry limit.
  /// 当任务达到其最大重试次数限制时发出。
  retryLimitReached
}