import 'fast_job_info.dart';
import 'typedef.dart';

/// Defines the interface for an asynchronous queue implementation.
/// 
/// This interface specifies the required methods that any async queue implementation
/// must provide. It ensures consistent behavior across different implementations
/// and allows for dependency injection and testing.
/// 
/// 定义异步队列实现的接口。
/// 
/// 此接口指定任何异步队列实现必须提供的必需方法。
/// 它确保不同实现之间的一致行为，并允许依赖注入和测试。
abstract class AsyncQueueInterface {
  /// Closes the queue, preventing new jobs from being added.
  /// Existing jobs in the queue will continue to be processed.
  /// 
  /// 关闭队列，防止添加新任务。
  /// 队列中的现有任务将继续处理。
  void close();
  
  /// Stops the queue processing and optionally executes a callback function.
  /// 
  /// Parameters:
  /// - [callBack]: An optional function to be called after stopping the queue
  /// 
  /// 停止队列处理，并可选地执行回调函数。
  /// 
  /// 参数：
  /// - [callBack]: 停止队列后可选的回调函数
  void stop([Function? callBack]);
  
  /// Clears all jobs from the queue and optionally executes a callback function.
  /// 
  /// Parameters:
  /// - [callBack]: An optional function to be called after clearing the queue
  /// 
  /// 清除队列中的所有任务，并可选地执行回调函数。
  /// 
  /// 参数：
  /// - [callBack]: 清除队列后可选的回调函数
  void clear([Function? callBack]);
  
  /// Retries the current job if it has failed.
  /// The behavior depends on the implementation and the job's retry configuration.
  /// 
  /// 如果当前任务失败，则重试该任务。
  /// 行为取决于实现和任务的重试配置。
  void retry();
  
  /// Adds a new asynchronous job to the queue.
  /// 
  /// Parameters:
  /// - [job]: The asynchronous function to be executed
  /// - [label]: An optional unique identifier for the job
  /// - [retryTime]: The number of retry attempts if the job fails
  /// 
  /// 向队列添加新的异步任务。
  /// 
  /// 参数：
  /// - [job]: 要执行的异步函数
  /// - [label]: 任务的可选唯一标识符
  /// - [retryTime]: 任务失败时的重试次数
  void addJob(AsyncJob job, {String? label, int retryTime});
  
  /// Adds a new job to the queue with strict error handling.
  /// This method should throw an exception if the queue is closed.
  /// 
  /// Parameters:
  /// - [job]: The asynchronous function to be executed
  /// 
  /// 向队列添加新任务，使用严格的错误处理。
  /// 如果队列已关闭，此方法应抛出异常。
  /// 
  /// 参数：
  /// - [job]: 要执行的异步函数
  void addJobThrow(AsyncJob job);
  
  /// Starts processing jobs in the queue.
  /// Returns a Future that completes when all jobs have been processed
  /// or the queue has been stopped.
  /// 
  /// 开始处理队列中的任务。
  /// 返回一个 Future，当所有任务都已处理或队列已停止时完成。
  Future<void> start();
  
  /// Returns a list of information about all jobs in the queue.
  /// 
  /// Returns a list of [JobInfo] objects containing the current state
  /// and metadata of each job in the queue.
  /// 
  /// 返回队列中所有任务的信息列表。
  /// 
  /// 返回包含队列中每个任务当前状态和元数据的 [JobInfo] 对象列表。
  List<JobInfo> list();
  
  /// Returns information about a specific job by its label.
  /// 
  /// Parameters:
  /// - [label]: The unique identifier of the job
  /// 
  /// Returns a [JobInfo] object containing the current state and metadata of the job.
  /// May throw an exception if no job with the specified label exists.
  /// 
  /// 通过标签返回特定任务的信息。
  /// 
  /// 参数：
  /// - [label]: 任务的唯一标识符
  /// 
  /// 返回包含任务当前状态和元数据的 [JobInfo] 对象。
  /// 如果不存在指定标签的任务，可能会抛出异常。
  JobInfo getJobInfo(String label);
}