import 'package:fast_package/fast_package.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('list delay is position times resolved delay', () {
    const FastListStagger stagger = FastListStagger.list(
      duration: Duration(milliseconds: 240),
      delay: Duration(milliseconds: 40),
    );
    expect(stagger.delayFor(0), Duration.zero);
    expect(stagger.delayFor(3), const Duration(milliseconds: 120));
  });

  test('default delay is duration / 6', () {
    const FastListStagger stagger = FastListStagger.list(
      duration: Duration(milliseconds: 240),
    );
    expect(stagger.resolvedDelay, const Duration(milliseconds: 40));
  });

  test('grid delay matches reference formula', () {
    const FastListStagger stagger = FastListStagger.grid(
      columnCount: 3,
      delay: Duration(milliseconds: 10),
    );
    // position 4 → row 1 + col 1 → 2 * 10
    expect(stagger.delayFor(4), const Duration(milliseconds: 20));
  });

  test('maxItems caps the last delay', () {
    const FastListStagger stagger = FastListStagger.list(
      delay: Duration(milliseconds: 10),
      maxItems: 3,
    );
    expect(stagger.delayFor(2), const Duration(milliseconds: 20));
    expect(stagger.delayFor(99), const Duration(milliseconds: 20));
  });

  test('interval stays inside 0..1', () {
    const FastListStagger stagger = FastListStagger.list(
      duration: Duration(milliseconds: 100),
      delay: Duration(milliseconds: 20),
      maxItems: 4,
    );
    final (double start, double end) = stagger.intervalFor(1);
    expect(start, inInclusiveRange(0, 1));
    expect(end, inInclusiveRange(start, 1));
  });

  test('none and synchronized report no per-item delay', () {
    expect(const FastListStagger.none().delayFor(4), Duration.zero);
    expect(const FastListStagger.synchronized().delayFor(4), Duration.zero);
    expect(const FastListStagger.none().isEnabled, isFalse);
  });
}
