library fast_package;

//节流防抖和限速
export 'src/utils/fast_debounce/fast_debounce.dart';
export 'src/utils/fast_throttle/fast_throttle.dart';
export 'src/utils/fast_rate_limit/fast_rate_limit.dart';
//扩展
export 'src/utils/fast_extension/bool_extension.dart';
export 'src/utils/fast_extension/string_extension.dart';
export 'src/utils/fast_extension/num_extension.dart';
export 'src/utils/fast_extension/int_extension.dart';
export 'src/utils/fast_extension/double_extension.dart';

//队列执行
export 'src/utils/fast_async_queue/fast_async_queue.dart';
export 'src/utils/fast_async_queue/fast_queue_event.dart';
export 'src/utils/fast_async_queue/fast_job_info.dart';
export 'src/utils/fast_async_queue/typedef.dart';
export 'src/utils/fast_async_queue/exceptions.dart';
export 'src/utils/fast_async_queue/enum.dart';
export 'src/utils/fast_async_queue/fast_async_node.dart' hide FastAsyncNode;

// ---------------------------ui kit---------------------------
export 'src/ui_kit/fast_gradient_borders/gradient_box_borders.dart';

// shimmer skeleton（显式骨架；不含 auto-detect）
export 'src/ui_kit/fast_shimmer/fast_shimmer.dart';
export 'src/ui_kit/fast_shimmer/fast_shimmer_direction.dart';
export 'src/ui_kit/fast_shimmer/fast_shimmer_scope.dart';
export 'src/ui_kit/fast_shimmer/fast_shimmer_theme.dart';
export 'src/ui_kit/fast_shimmer/widgets/fast_shimmer_box.dart';
export 'src/ui_kit/fast_shimmer/widgets/fast_shimmer_circle.dart';
export 'src/ui_kit/fast_shimmer/widgets/fast_shimmer_list.dart';
export 'src/ui_kit/fast_shimmer/widgets/fast_shimmer_text.dart';

// toast（showToast / showCustomToast；无 type）
export 'src/ui_kit/fast_toast/fast_toast.dart';
export 'src/ui_kit/fast_toast/fast_toast_overlay.dart';
export 'src/ui_kit/fast_toast/fast_toast_theme.dart';
export 'src/ui_kit/fast_toast/fast_toast_config.dart';
export 'src/ui_kit/fast_toast/fast_toast_position.dart';

// ---------------------------scan utils---------------------------
export 'src/utils/fast_scan/fast_scan.dart';
