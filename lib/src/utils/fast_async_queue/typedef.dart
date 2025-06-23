import 'fast_queue_event.dart';

/// Represents an asynchronous job function that returns a Future.
/// 
/// This is the core function type used for tasks in the async queue.
/// Each job must be an asynchronous function that returns a Future.
/// The function takes no parameters and is expected to handle any
/// required inputs through closures or other mechanisms.
/// 
/// 表示返回 Future 的异步任务函数。
/// 
/// 这是异步队列中用于任务的核心函数类型。
/// 每个任务必须是返回 Future 的异步函数。
/// 该函数不接受参数，预期通过闭包或其他机制处理任何所需的输入。
typedef AsyncJob = Future Function();

/// Represents a listener function for queue events.
/// 
/// This function type is used to receive and handle events emitted by the queue.
/// Queue listeners are registered with the queue and are called whenever
/// a queue event occurs, such as when a job is added, started, completed, or failed.
/// 
/// Parameters:
/// - [event]: The queue event that occurred
/// 
/// 表示队列事件的监听器函数。
/// 
/// 此函数类型用于接收和处理队列发出的事件。
/// 队列监听器注册到队列，并在队列事件发生时被调用，
/// 例如当任务被添加、开始、完成或失败时。
/// 
/// 参数：
/// - [event]: 发生的队列事件
typedef QueueListener = Function(QueueEvent event);
