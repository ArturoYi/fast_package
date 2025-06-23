import 'enum.dart';

/// Represents an event that occurs in the async queue.
/// 
/// Queue events are emitted by the queue and can be received by registered listeners.
/// Each event contains information about the queue's state at the time of the event,
/// including the event type, queue size, and timestamp.
/// 
/// 表示异步队列中发生的事件。
/// 
/// 队列事件由队列发出，可以被注册的监听器接收。
/// 每个事件包含事件发生时队列状态的信息，
/// 包括事件类型、队列大小和时间戳。
class QueueEvent {
  /// The timestamp when the event occurred.
  /// Automatically set to the current time when the event is created.
  /// 
  /// 事件发生的时间戳。
  /// 在创建事件时自动设置为当前时间。
  final DateTime time = DateTime.now();
  
  /// The number of jobs in the queue at the time of the event.
  /// This provides a snapshot of the queue size when the event occurred.
  /// 
  /// 事件发生时队列中的任务数量。
  /// 这提供了事件发生时队列大小的快照。
  final int currentQueueSize;
  
  /// The type of queue event that occurred.
  /// This indicates what action or state change triggered the event.
  /// 
  /// 发生的队列事件类型。
  /// 这表示触发事件的操作或状态变化。
  final QueueEventType type;
  
  /// The label of the job associated with this event, if applicable.
  /// This will be null for events that are not related to a specific job.
  /// 
  /// 与此事件关联的任务标签（如果适用）。
  /// 对于与特定任务无关的事件，此值将为 null。
  final String? jobLabel;

  /// Creates a new queue event with the specified properties.
  /// 
  /// Parameters:
  /// - [currentQueueSize]: The number of jobs in the queue at the time of the event
  /// - [type]: The type of queue event that occurred
  /// - [jobLabel]: The label of the job associated with this event (optional)
  /// 
  /// 创建具有指定属性的新队列事件。
  /// 
  /// 参数：
  /// - [currentQueueSize]: 事件发生时队列中的任务数量
  /// - [type]: 发生的队列事件类型
  /// - [jobLabel]: 与此事件关联的任务标签（可选）
  QueueEvent({
    required this.currentQueueSize,
    required this.type,
    this.jobLabel,
  });

  /// Returns a string representation of this queue event.
  /// 
  /// Includes the queue size, event type, job label (if any), and timestamp.
  /// Useful for debugging and logging purposes.
  /// 
  /// 返回此队列事件的字符串表示形式。
  /// 
  /// 包括队列大小、事件类型、任务标签（如果有）和时间戳。
  /// 对调试和日志记录很有用。
  @override
  String toString() =>
      'QueueEvent [currentQueueSize: $currentQueueSize, type: $type, jobLabel: $jobLabel, at: $time]';
}
