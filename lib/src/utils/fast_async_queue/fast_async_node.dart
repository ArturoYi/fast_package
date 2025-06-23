import 'enum.dart';
import 'fast_job_info.dart';
import 'typedef.dart';

/// A node in the async queue that contains an asynchronous job.
/// Each node represents a single task in the queue with its associated metadata.
/// 
/// AsyncNode is responsible for:
/// - Storing the job function to be executed
/// - Tracking the job's state and retry information
/// - Providing job execution functionality
/// - Linking to the next node in the queue
/// 
/// 异步队列中包含异步任务的节点。
/// 每个节点表示队列中的单个任务及其相关元数据。
/// 
/// AsyncNode 负责：
/// - 存储要执行的任务函数
/// - 跟踪任务的状态和重试信息
/// - 提供任务执行功能
/// - 链接到队列中的下一个节点
class FastAsyncNode {
  /// The asynchronous job function to be executed.
  /// 要执行的异步任务函数。
  final AsyncJob _job;
  
  /// The maximum number of retry attempts allowed for this job.
  /// A value of -1 indicates unlimited retries.
  /// 此任务允许的最大重试次数。
  /// 值为 -1 表示无限重试。
  final int maxRetry;
  
  /// A unique identifier for this job.
  /// Used for tracking and retrieving job information.
  /// 此任务的唯一标识符。
  /// 用于跟踪和检索任务信息。
  final String label;
  
  /// An optional description of the job.
  /// 任务的可选描述。
  final String? description;

  /// Reference to the next node in the queue.
  /// Used to maintain the linked list structure of the queue.
  /// 队列中下一个节点的引用。
  /// 用于维护队列的链表结构。
  FastAsyncNode? next;
  
  /// The current number of retry attempts that have been made for this job.
  /// 此任务已进行的当前重试次数。
  int retryCount = 0;
  
  /// The current state of the job in the queue.
  /// 任务在队列中的当前状态。
  JobState state = JobState.pending;

  /// Creates a new async node with the specified job and metadata.
  /// 
  /// Parameters:
  /// - [job]: The asynchronous function to be executed
  /// - [label]: A unique identifier for the job
  /// - [description]: An optional description of the job
  /// - [maxRetry]: The maximum number of retry attempts (default: 1)
  /// 
  /// 创建具有指定任务和元数据的新异步节点。
  /// 
  /// 参数：
  /// - [job]: 要执行的异步函数
  /// - [label]: 任务的唯一标识符
  /// - [description]: 任务的可选描述
  /// - [maxRetry]: 最大重试次数（默认值：1）
  FastAsyncNode({
    required AsyncJob job,
    required this.label,
    this.description,
    this.maxRetry = 1,
  }) : _job = job;

  /// Executes the job function and updates the node's state.
  /// 
  /// Sets the job state to [JobState.running] before execution.
  /// The state after execution will be updated by the queue manager
  /// based on the success or failure of the job.
  /// 
  /// 执行任务函数并更新节点的状态。
  /// 
  /// 在执行前将任务状态设置为 [JobState.running]。
  /// 执行后的状态将由队列管理器根据任务的成功或失败进行更新。
  Future run() async {
    state = JobState.running;
    await _job();
  }

  /// Returns a string representation of this node.
  /// 
  /// Includes the node's label, description, retry count, and maximum retries.
  /// Useful for debugging and logging purposes.
  /// 
  /// 返回此节点的字符串表示形式。
  /// 
  /// 包括节点的标签、描述、重试次数和最大重试次数。
  /// 对调试和日志记录很有用。
  @override
  String toString() {
    return 'AsyncNode(maxRetry: $maxRetry, label: $label, description: $description, retryCount: $retryCount)';
  }

  /// Creates a [JobInfo] object containing the current state and metadata of this job.
  /// 
  /// This provides a snapshot of the job's current status that can be
  /// safely passed outside the queue implementation.
  /// 
  /// 创建包含此任务当前状态和元数据的 [JobInfo] 对象。
  /// 
  /// 这提供了任务当前状态的快照，可以安全地传递到队列实现之外。
  JobInfo get info => JobInfo(
        label: label,
        description: description,
        maxRetry: maxRetry,
        retryCount: retryCount,
        state: state,
      );
}