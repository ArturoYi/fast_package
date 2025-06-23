import 'enum.dart';

/// Represents information about a job in the async queue.
/// 
/// This class provides a snapshot of a job's current state and metadata,
/// allowing for monitoring and inspection of jobs in the queue.
/// This information can be obtained by calling [FastAsyncQueue.list] or [FastAsyncQueue.getJobInfo].
/// 
/// 表示异步队列中任务的信息。
/// 
/// 此类提供任务当前状态和元数据的快照，
/// 允许监控和检查队列中的任务。
/// 可以通过调用 [FastAsyncQueue.list] 或 [FastAsyncQueue.getJobInfo] 获取此信息。
class JobInfo {
  /// The unique identifier of the job.
  /// 任务的唯一标识符。
  final String label;
  
  /// An optional description of the job.
  /// 任务的可选描述。
  final String? description;
  
  /// The current state of the job in the queue.
  /// 任务在队列中的当前状态。
  final JobState state;
  
  /// The number of retry attempts that have been made for this job.
  /// 此任务已进行的重试次数。
  final int retryCount;
  
  /// The maximum number of retry attempts allowed for this job.
  /// 此任务允许的最大重试次数。
  final int maxRetry;
  /// Creates a new job information object with the specified properties.
  /// 
  /// Parameters:
  /// - [label]: The unique identifier of the job
  /// - [description]: An optional description of the job
  /// - [state]: The current state of the job
  /// - [retryCount]: The number of retry attempts made
  /// - [maxRetry]: The maximum number of retry attempts allowed
  /// 
  /// 创建具有指定属性的新任务信息对象。
  /// 
  /// 参数：
  /// - [label]: 任务的唯一标识符
  /// - [description]: 任务的可选描述
  /// - [state]: 任务的当前状态
  /// - [retryCount]: 已进行的重试次数
  /// - [maxRetry]: 允许的最大重试次数
  JobInfo({
    required this.label,
    this.description,
    required this.state,
    required this.retryCount,
    required this.maxRetry,
  });

  /// Compares this job information with another object for equality.
  /// 
  /// Two [JobInfo] objects are considered equal if all their properties are equal.
  /// 
  /// 比较此任务信息与另一个对象是否相等。
  /// 
  /// 如果两个 [JobInfo] 对象的所有属性都相等，则它们被视为相等。
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JobInfo &&
        other.label == label &&
        other.description == description &&
        other.state == state &&
        other.retryCount == retryCount &&
        other.maxRetry == maxRetry;
  }

  /// Calculates a hash code for this job information.
  /// 
  /// The hash code is based on all properties of the job information.
  /// This is used for efficient storage in hash-based collections.
  /// 
  /// 计算此任务信息的哈希码。
  /// 
  /// 哈希码基于任务信息的所有属性。
  /// 这用于在基于哈希的集合中进行高效存储。
  @override
  int get hashCode {
    return label.hashCode ^
        description.hashCode ^
        state.hashCode ^
        retryCount.hashCode ^
        maxRetry.hashCode;
  }

  /// Creates a copy of this job information with the specified properties replaced.
  /// 
  /// This method allows for creating a new [JobInfo] object based on this one,
  /// but with some properties changed. Properties that are not specified
  /// will retain their current values.
  /// 
  /// Parameters:
  /// - [label]: The new label (optional)
  /// - [description]: The new description (optional)
  /// - [state]: The new state (optional)
  /// - [retryCount]: The new retry count (optional)
  /// - [maxRetry]: The new maximum retry count (optional)
  /// 
  /// Returns a new [JobInfo] object with the specified properties replaced.
  /// 
  /// 创建此任务信息的副本，并替换指定的属性。
  /// 
  /// 此方法允许基于当前对象创建新的 [JobInfo] 对象，
  /// 但更改了某些属性。未指定的属性将保留其当前值。
  /// 
  /// 参数：
  /// - [label]: 新标签（可选）
  /// - [description]: 新描述（可选）
  /// - [state]: 新状态（可选）
  /// - [retryCount]: 新重试次数（可选）
  /// - [maxRetry]: 新最大重试次数（可选）
  /// 
  /// 返回一个新的 [JobInfo] 对象，其中指定的属性已被替换。
  JobInfo copyWith({
    String? label,
    String? description,
    JobState? state,
    int? retryCount,
    int? maxRetry,
  }) {
    return JobInfo(
      label: label ?? this.label,
      description: description ?? this.description,
      state: state ?? this.state,
      retryCount: retryCount ?? this.retryCount,
      maxRetry: maxRetry ?? this.maxRetry,
    );
  }

  /// Returns a string representation of this job information.
  /// 
  /// Includes all properties of the job information.
  /// Useful for debugging and logging purposes.
  /// 
  /// 返回此任务信息的字符串表示形式。
  /// 
  /// 包括任务信息的所有属性。
  /// 对调试和日志记录很有用。
  @override
  String toString() {
    return 'JobInfo(label: $label, description: $description, state: $state, retryCount: $retryCount, maxRetry: $maxRetry)\n';
  }
}
