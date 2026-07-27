---
title: Size Calculation Tools
---

### Size Calculation Tools

Provides intelligent size calculation and adaptation tools, implementing a cover-fit algorithm similar to CSS's `object-fit: cover`.

#### 1. Cover Scan Size Calculation (fastCoverScanSize)

Calculates the optimal size for a child element to cover its parent container while maintaining aspect ratio.

```dart
import 'package:fast_package/fast_package.dart';

// Calculate cover scan size
Size parentSize = Size(100, 100);
Size childSize = Size(50, 80);
Size result = fastCoverScanSize(parentSize, childSize);
// Result: Size(100, 160) - scaled proportionally by width

// Examples with different aspect ratios
Size parent = Size(200, 100);  // Landscape rectangle
Size child = Size(100, 100);   // Square
Size result = fastCoverScanSize(parent, child);
// Result: Size(200, 200) - scaled by width, maintaining square aspect ratio
```

#### 2. Cover Scan Scale Calculation (fastCoverScanScale)

Gets the scaling ratio needed for a child element to cover its parent container, returning the scaling factor instead of the calculated size.

```dart
import 'package:fast_package/fast_package.dart';

// Basic usage
Size parentSize = Size(100, 100);
Size childSize = Size(50, 50);
double scale = fastCoverScanScale(parentSize, childSize);
// Result: 2.0 - needs to scale by width by 2x

// Case where child already covers parent
Size parent = Size(100, 100);
Size child = Size(200, 100);  // Child is wider
double scale = fastCoverScanScale(parent, child);
// Result: 1.0 - no scaling needed, child already covers

// Case where scaling by height is needed
Size parent = Size(100, 100);
Size child = Size(100, 50);   // Child is taller
double scale = fastCoverScanScale(parent, child);
// Result: 2.0 - needs to scale by height by 2x
```

#### Algorithm Principle

The size calculation tools are based on the following algorithm:

1. **Aspect Ratio Comparison**: Calculate the aspect ratios (width/height) of both parent and child
2. **Scaling Strategy Selection**:
   - If parent aspect ratio ≥ child aspect ratio: scale by width
   - If parent aspect ratio < child aspect ratio: scale by height
3. **Boundary Handling**: Handle edge cases like zero dimensions

#### Use Cases

- **Image Adaptation**: Ensure images completely cover containers without distortion
- **Video Players**: Adapt video content to different player sizes
- **Background Images**: Background images completely covering containers
- **Responsive Layout**: Content adaptation on different device sizes

#### Practical Application Example

```dart
// Image adaptation example
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
        // Get the original size of the image (assumed known here)
        Size imageSize = Size(800, 600); // In practice, get from image
        Size containerSize = Size(containerWidth, containerHeight);
        
        // Calculate the adapted size
        Size adaptedSize = fastCoverScanSize(containerSize, imageSize);
        
        // Or get the scaling ratio
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
