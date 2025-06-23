/// Exception thrown when attempting to add a job to a closed queue.
/// This exception is thrown by [FastAsyncQueue.addJobThrow] when the queue is closed.
/// 
/// 当尝试向已关闭的队列添加任务时抛出的异常。
/// 当队列关闭时，由 [FastAsyncQueue.addJobThrow] 方法抛出此异常。
class ClosedQueueException implements Exception {
  /// The error message describing the exception.
  /// 描述异常的错误消息。
  final String message;
  
  /// Creates a new [ClosedQueueException] with the specified error message.
  /// 使用指定的错误消息创建新的 [ClosedQueueException]。
  ClosedQueueException(this.message);
}

/// Exception thrown when attempting to add a job with a label that already exists in the queue.
/// This exception is thrown by [FastAsyncQueue.addJob] and [FastAsyncQueue.addJobThrow] when a duplicate label is detected.
/// 
/// 当尝试添加一个标签已存在于队列中的任务时抛出的异常。
/// 当检测到重复标签时，由 [FastAsyncQueue.addJob] 和 [FastAsyncQueue.addJobThrow] 方法抛出此异常。
class DuplicatedLabelException implements Exception {
  /// The error message describing the exception.
  /// 描述异常的错误消息。
  final String message;
  
  /// Creates a new [DuplicatedLabelException] with the specified error message.
  /// 使用指定的错误消息创建新的 [DuplicatedLabelException]。
  DuplicatedLabelException(this.message);
}

/// Exception thrown when attempting to access a job with a label that does not exist in the queue.
/// This exception is thrown by [FastAsyncQueue.getJobInfo] when an invalid label is provided.
/// 
/// 当尝试访问一个标签不存在于队列中的任务时抛出的异常。
/// 当提供无效标签时，由 [FastAsyncQueue.getJobInfo] 方法抛出此异常。
class InvalidJobLabelException implements Exception {
  /// The error message describing the exception.
  /// 描述异常的错误消息。
  final String message;
  
  /// Creates a new [InvalidJobLabelException] with the specified error message.
  /// 使用指定的错误消息创建新的 [InvalidJobLabelException]。
  InvalidJobLabelException(this.message);
}