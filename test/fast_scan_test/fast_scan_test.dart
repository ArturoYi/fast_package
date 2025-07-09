import 'package:fast_package/fast_package.dart';
import 'package:flutter/painting.dart';
import 'package:test/test.dart';

void main() {
  group("test fastCoverScanSize", () {
    test('零维度边界情况测试', () {
      // 父元素尺寸为0，应返回子元素尺寸
      Size parentSize = const Size(0, 0);
      Size childSize = const Size(100, 100);
      Size result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素尺寸为0，应返回父元素尺寸
      parentSize = const Size(100, 100);
      childSize = const Size(0, 0);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(parentSize));

      // 父元素和子元素尺寸都为0，应返回父元素尺寸
      parentSize = const Size(0, 0);
      childSize = const Size(0, 0);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(parentSize));

      // 父元素宽度为0，应返回子元素尺寸
      parentSize = const Size(0, 100);
      childSize = const Size(50, 50);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 父元素高度为0，应返回子元素尺寸
      parentSize = const Size(100, 0);
      childSize = const Size(50, 50);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));
    });

    test('子元素完全覆盖父元素的情况', () {
      Size parentSize = const Size(100, 100);
      
      // 子元素在两个维度上都大于父元素
      Size childSize = const Size(200, 200);
      Size result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素宽度等于父元素，高度大于父元素
      childSize = const Size(100, 200);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素高度等于父元素，宽度大于父元素
      childSize = const Size(200, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素尺寸与父元素完全相同
      childSize = const Size(100, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));
    });

    test('按宽度缩放能覆盖父元素的情况', () {
      Size parentSize = const Size(100, 100);
      
      // 子元素宽度小于父元素，按宽度缩放后高度能覆盖父元素
      Size childSize = const Size(50, 200);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(100, 400); // 宽度100，高度按比例缩放
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));

      // 子元素宽度等于父元素宽度，高度大于父元素
      childSize = const Size(100, 150);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素宽度小于父元素，按宽度缩放后高度刚好等于父元素高度
      childSize = const Size(50, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(100, 200);
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));
    });

    test('按高度缩放能覆盖父元素的情况', () {
      Size parentSize = const Size(100, 100);
      
      // 子元素高度小于父元素，按高度缩放后宽度能覆盖父元素
      Size childSize = const Size(200, 50);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(400, 100); // 高度100，宽度按比例缩放
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));

      // 子元素高度等于父元素高度，宽度大于父元素
      childSize = const Size(150, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 子元素高度小于父元素，按高度缩放后宽度刚好等于父元素宽度
      childSize = const Size(100, 50);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(200, 100);
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));
    });

    test('子元素在两个维度上都小于父元素的情况', () {
      Size parentSize = const Size(100, 100);
      
      // 子元素在两个维度上都小于父元素，但按宽度缩放后高度能覆盖
      Size childSize = const Size(50, 60);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(100, 120); // 按宽度缩放：100/50=2，高度60*2=120
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));

      // 子元素在两个维度上都小于父元素，按宽度缩放后高度不能覆盖，需要按高度缩放
      childSize = const Size(60, 50);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(120, 100); // 按高度缩放：100/50=2，宽度60*2=120
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));
    });

    test('不同宽高比的测试', () {
      // 父元素为正方形，子元素为横向矩形
      Size parentSize = const Size(100, 100);
      Size childSize = const Size(200, 100);
      Size result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 父元素为正方形，子元素为纵向矩形
      childSize = const Size(100, 200);
      result = fastCoverScanSize(parentSize, childSize);
      expect(result, equals(childSize));

      // 父元素为横向矩形，子元素为正方形
      parentSize = const Size(200, 100);
      childSize = const Size(100, 100);
      result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(200, 200); // 按宽度缩放
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));

      // 父元素为纵向矩形，子元素为正方形
      parentSize = const Size(100, 200);
      childSize = const Size(100, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(200, 200); // 按高度缩放
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));
    });

    test('复杂比例测试', () {
      // 父元素 16:9，子元素 4:3
      Size parentSize = const Size(1600, 900);
      Size childSize = const Size(400, 300);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(1600, 1200); // 按宽度缩放：1600/400=4，高度300*4=1200
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));

      // 父元素 4:3，子元素 16:9
      parentSize = const Size(400, 300);
      childSize = const Size(1600, 900);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(1600, 900); // 子元素已经覆盖父元素，返回原始尺寸
      expect(result, equals(expected));

      // 父元素 1:1，子元素 3:2
      parentSize = const Size(100, 100);
      childSize = const Size(150, 100);
      result = fastCoverScanSize(parentSize, childSize);
      expected = const Size(150, 100); // 子元素已经覆盖父元素
      expect(result, equals(expected));
    });

    test('小数精度测试', () {
      // 测试小数精度
      Size parentSize = const Size(100.5, 100.5);
      Size childSize = const Size(50.25, 75.375);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(100.5, 150.75); // 按宽度缩放：100.5/50.25=2，高度75.375*2=150.75
      expect((result.width - expected.width).abs(), lessThan(0.01));
      expect((result.height - expected.height).abs(), lessThan(0.01));
    });

    test('极大数值测试', () {
      // 测试极大数值
      Size parentSize = const Size(1000000, 1000000);
      Size childSize = const Size(500000, 750000);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(1000000, 1500000); // 按宽度缩放
      expect(result.width, equals(expected.width));
      expect(result.height, equals(expected.height));
    });

    test('极小数值测试', () {
      // 测试极小数值
      Size parentSize = const Size(0.001, 0.001);
      Size childSize = const Size(0.0005, 0.00075);
      Size result = fastCoverScanSize(parentSize, childSize);
      Size expected = const Size(0.001, 0.0015); // 按宽度缩放
      expect((result.width - expected.width).abs(), lessThan(0.000001));
      expect((result.height - expected.height).abs(), lessThan(0.000001));
    });

    test('兜底情况测试', () {
      // 测试理论上不应该发生但作为安全措施的兜底情况
      // 这种情况在实际使用中很难遇到，但函数有相应的处理
      Size parentSize = const Size(100, 100);
      Size childSize = const Size(50, 50);
      Size result = fastCoverScanSize(parentSize, childSize);
      // 按宽度缩放：100/50=2，高度50*2=100，刚好覆盖
      Size expected = const Size(100, 100);
      expect(result, equals(expected));
      
      // 测试一个更复杂的兜底情况
      parentSize = const Size(100, 100);
      childSize = const Size(30, 40);
      result = fastCoverScanSize(parentSize, childSize);
      // 按宽度缩放：100/30≈3.33，高度40*3.33≈133.33，能覆盖
      expected = const Size(100, 133.33);
      expect(result.width, equals(expected.width));
      expect((result.height - expected.height).abs(), lessThan(0.1));
    });
  });
} 