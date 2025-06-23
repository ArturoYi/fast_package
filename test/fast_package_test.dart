import 'fast_debounce_test/fast_debounce_test.dart' as fast_debounce_test;
import 'fast_throttle_test/fast_throttle_test.dart' as fast_throttle_test;
import 'fast_rate_limit_test/fast_rate_limit_test.dart' as fast_rate_limit_test;
import 'fast_string_extension_test/fast_string_extension_test.dart'
    as fast_string_extension_test;
import 'fast_num_extension_test/fast_num_extension_test.dart'
    as fast_num_extension_test;
import 'fast_async_queue_test/fast_async_queue_test.dart' as fast_async_queue_test;
import 'fast_async_queue_test/fast_async_queue_retry_test.dart' as fast_async_queue_retry_test;
import 'fast_async_queue_test/fast_async_queue_info_test.dart' as fast_async_queue_info_test;

void main() {
  fast_debounce_test.main();
  fast_throttle_test.main();
  fast_rate_limit_test.main();
  fast_string_extension_test.main();
  fast_num_extension_test.main();
  fast_async_queue_test.main();
  fast_async_queue_retry_test.main();
  fast_async_queue_info_test.main();
}
