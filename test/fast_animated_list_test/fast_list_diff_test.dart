import 'package:fast_package/src/ui_kit/fast_animated_list/animation/fast_list_diff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const FastListDiffer differ = FastListDiffer();

  test('identical lists produce no ops', () {
    expect(
      differ.compute(<Object>['a', 'b'], <Object>['a', 'b']).isEmpty,
      isTrue,
    );
  });

  test('append inserts at the end', () {
    final FastListDiff diff = differ.compute(
      <Object>['a', 'b'],
      <Object>['a', 'b', 'c'],
    );
    expect(diff.ops, <FastListOp>[const FastListInsertOp(2, 'c')]);
    expect(diff.isTailAppend, isTrue);
  });

  test('batch append is a tail append', () {
    final FastListDiff diff = differ.compute(
      <Object>['a', 'b'],
      <Object>['a', 'b', 'c', 'd', 'e'],
    );
    expect(diff.isTailAppend, isTrue);
  });

  test('head insert is not a tail append', () {
    final FastListDiff diff = differ.compute(
      <Object>['b', 'c'],
      <Object>['a', 'b', 'c'],
    );
    expect(diff.isTailAppend, isFalse);
  });

  test('empty to items is not a tail append', () {
    final FastListDiff diff = differ.compute(
      <Object>[],
      <Object>['a', 'b'],
    );
    expect(diff.isTailAppend, isFalse);
  });

  test('remove is not a tail append', () {
    final FastListDiff diff = differ.compute(
      <Object>['a', 'b', 'c'],
      <Object>['a', 'c'],
    );
    expect(diff.isTailAppend, isFalse);
  });

  test('single remove uses a descending index', () {
    final FastListDiff diff = differ.compute(
      <Object>['a', 'b', 'c'],
      <Object>['a', 'c'],
    );
    expect(diff.ops, <FastListOp>[const FastListRemoveOp(1)]);
  });

  test('detects a single move down', () {
    expect(
      FastListDiffer.detectSingleMove(
        <Object>['a', 'b', 'c', 'd'],
        <Object>['a', 'c', 'd', 'b'],
      ),
      const FastListMoveOp(1, 3),
    );
  });

  test('detects a single move up', () {
    expect(
      FastListDiffer.detectSingleMove(
        <Object>['a', 'b', 'c', 'd'],
        <Object>['a', 'd', 'b', 'c'],
      ),
      const FastListMoveOp(3, 1),
    );
  });

  test('single move is preferred over a permutation of moves', () {
    final FastListDiff diff = differ.compute(
      <Object>['a', 'b', 'c', 'd'],
      <Object>['a', 'c', 'd', 'b'],
    );
    expect(diff.ops, <FastListOp>[const FastListMoveOp(1, 3)]);
  });

  test('empty to many over budget snaps', () {
    final FastListDiff diff = const FastListDiffer(animationBudget: 2).compute(
      <Object>[],
      <Object>['a', 'b', 'c'],
    );
    expect(diff.reset, isTrue);
  });

  test('replace-all over budget snaps', () {
    final FastListDiff diff = const FastListDiffer(animationBudget: 2).compute(
      <Object>['a', 'b', 'c'],
      <Object>['x', 'y', 'z'],
    );
    expect(diff.reset, isTrue);
  });

  test('insert then remaining items keep order', () {
    final FastListDiff diff = differ.compute(
      <Object>['b', 'c'],
      <Object>['a', 'b', 'c'],
    );
    expect(diff.ops, <FastListOp>[const FastListInsertOp(0, 'a')]);
  });
}
