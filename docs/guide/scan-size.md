---
title: 尺寸计算工具
---

### 尺寸计算工具

提供智能的尺寸计算和适配工具，实现类似 CSS 中 `object-fit: cover` 的覆盖适配算法。

#### 1. 覆盖扫描尺寸计算 (fastCoverScanSize)

计算子元素覆盖父容器的最佳尺寸，保持原始宽高比。

```dart
import 'package:fast_package/fast_package.dart';

// 计算覆盖扫描尺寸
Size parentSize = Size(100, 100);
Size childSize = Size(50, 80);
Size result = fastCoverScanSize(parentSize, childSize);
// 结果: Size(100, 160) - 按宽度等比例拉伸

// 不同宽高比的示例
Size parent = Size(200, 100);  // 横向矩形
Size child = Size(100, 100);   // 正方形
Size result = fastCoverScanSize(parent, child);
// 结果: Size(200, 200) - 按宽度缩放，保持正方形比例
```

#### 2. 覆盖扫描缩放比例 (fastCoverScanScale)

获取子元素覆盖父容器所需的缩放比例，返回缩放因子而不是计算后的尺寸。

```dart
import 'package:fast_package/fast_package.dart';

// 基本使用
Size parentSize = Size(100, 100);
Size childSize = Size(50, 50);
double scale = fastCoverScanScale(parentSize, childSize);
// 结果: 2.0 - 需要按宽度缩放2倍

// 子元素已经覆盖父元素的情况
Size parent = Size(100, 100);
Size child = Size(200, 100);  // 子元素更宽
double scale = fastCoverScanScale(parent, child);
// 结果: 1.0 - 无需缩放，子元素已经覆盖

// 按高度缩放的情况
Size parent = Size(100, 100);
Size child = Size(100, 50);   // 子元素更高
double scale = fastCoverScanScale(parent, child);
// 结果: 2.0 - 需要按高度缩放2倍
```

#### 算法原理

尺寸计算工具基于以下算法：

1. **宽高比比较**: 计算父容器和子元素的宽高比 (宽度/高度)
2. **缩放策略选择**:
   - 如果父容器宽高比 ≥ 子元素宽高比：按宽度缩放
   - 如果父容器宽高比 < 子元素宽高比：按高度缩放
3. **边界处理**: 处理零维度等边界情况

#### 使用场景

- **图片适配**: 确保图片完全覆盖容器而不变形
- **视频播放器**: 视频内容适配不同尺寸的播放器
- **背景图片**: 背景图片完全覆盖容器
- **响应式布局**: 内容在不同尺寸设备上的适配

#### 实际应用示例

```dart
// 图片适配示例
class AdaptiveImage extends StatelessWidget {
  final String imageUrl;
  final double containerWidth;
  final double containerHeight;

  const AdaptiveImage({
    required this.imageUrl,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取图片的原始尺寸（这里假设已知）
        Size imageSize = Size(800, 600); // 实际应用中从图片获取
        Size containerSize = Size(containerWidth, containerHeight);
        
        // 计算适配后的尺寸
        Size adaptedSize = fastCoverScanSize(containerSize, imageSize);
        
        // 或者获取缩放比例
        double scale = fastCoverScanScale(containerSize, imageSize);
        
        return Container(
          width: containerWidth,
          height: containerHeight,
          child: ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Image.network(
                imageUrl,
                width: imageSize.width,
                height: imageSize.height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
```
