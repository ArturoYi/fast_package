import 'package:fast_package/fast_package.dart';
import 'package:fast_package/src/utils/fast_async_queue/enum.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const mil100 = Duration(milliseconds: 100);
void main() {
  test(
    "job info List should be same size as queue size at max ",
    () async {
      final q = FastAsyncQueue();
      q.addJob(() => Future.delayed(mil100, () {}));
      q.addJob(() => Future.delayed(mil100, () {}));
      q.addJob(() => Future.delayed(mil100, () {}));
      q.addJob(() => Future.delayed(mil100, () {}));

      expect(q.list().length, q.size);

      await q.start();
      expect(q.list().length, 4);
      expect(q.size, 0);

      q.clear();
      expect(q.list().length, 0);
    },
  );
  test(
    "job info List should contain info of failed job",
    () async {
      final q = FastAsyncQueue();
      q.addJob(() => Future.delayed(mil100, () {}));
      q.addJob(() => Future.delayed(mil100, q.retry), label: "retryJob");
      q.addJob(() => Future.delayed(mil100, () {}));

      await q.start();
      print(q.list());
      final theJob = q.getJobInfo("retryJob");

      expect(theJob, isNotNull);
      expect(theJob.state, JobState.failed);
    },
  );
}