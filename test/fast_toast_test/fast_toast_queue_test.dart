import 'package:fast_package/src/ui_kit/fast_toast/fast_toast_queue.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastToastQueue', () {
    late FastToastQueue queue;

    setUp(() {
      queue = FastToastQueue();
    });

    test('enqueue and dequeue follow FIFO', () {
      queue.enqueue(const FastToastRequest.text('first'));
      queue.enqueue(const FastToastRequest.text('second'));

      expect(queue.length, 2);
      expect(queue.dequeue()?.message, 'first');
      expect(queue.dequeue()?.message, 'second');
      expect(queue.dequeue(), isNull);
      expect(queue.isEmpty, isTrue);
    });

    test('first returns head without removing', () {
      queue.enqueue(const FastToastRequest.text('only'));

      expect(queue.first?.message, 'only');
      expect(queue.length, 1);
    });

    test('clear removes all pending items', () {
      queue.enqueue(const FastToastRequest.text('a'));
      queue.enqueue(const FastToastRequest.text('b'));

      queue.clear();

      expect(queue.isEmpty, isTrue);
      expect(queue.dequeue(), isNull);
    });

    test('drop-oldest when pending reaches maxPending', () {
      for (int i = 0; i < FastToastQueue.maxPending + 1; i++) {
        queue.enqueue(FastToastRequest.text('msg$i'));
      }

      expect(queue.length, FastToastQueue.maxPending);
      expect(queue.first?.message, 'msg1');
      expect(queue.dequeue()?.message, 'msg1');
      expect(queue.dequeue()?.message, 'msg2');
      expect(queue.dequeue()?.message, 'msg3');
      expect(queue.dequeue()?.message, 'msg4');
      expect(queue.dequeue()?.message, 'msg5');
      expect(queue.dequeue(), isNull);
    });

    test('mixes text and custom widget requests in FIFO order', () {
      const Widget custom = SizedBox(key: Key('custom'));
      queue.enqueue(const FastToastRequest.text('a'));
      queue.enqueue(const FastToastRequest.custom(custom));
      queue.enqueue(const FastToastRequest.text('c'));

      final FastToastRequest first = queue.dequeue()!;
      expect(first.isText, isTrue);
      expect(first.message, 'a');

      final FastToastRequest second = queue.dequeue()!;
      expect(second.isText, isFalse);
      expect(second.child, same(custom));

      expect(queue.dequeue()?.message, 'c');
    });
  });
}
