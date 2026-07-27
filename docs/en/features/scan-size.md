---
title: Size Calculation Tools
---

### Size Calculation Tools

Smart sizing helpers—cover-fit behavior similar to CSS `object-fit: cover`.

#### 1. Cover scan size (`fastCoverScanSize`)

Computes the size a child needs to fully cover its parent while keeping aspect ratio.

```dart
import 'package:fast_package/fast_package.dart';

// Cover scan size
Size parentSize = Size(100, 100);
Size childSize = Size(50, 80);
Size result = fastCoverScanSize(parentSize, childSize);
// Result: Size(100, 160) — scaled proportionally by width

// Different aspect ratios
Size parent = Size(200, 100);  // Wide rectangle
Size child = Size(100, 100);   // Square
Size result = fastCoverScanSize(parent, child);
// Result: Size(200, 200) — scaled by width, square ratio preserved
```

#### 2. Cover scan scale (`fastCoverScanScale`)

Returns the scale factor for a child to cover its parent (not the final size).

```dart
import 'package:fast_package/fast_package.dart';

// Basic usage
Size parentSize = Size(100, 100);
Size childSize = Size(50, 50);
double scale = fastCoverScanScale(parentSize, childSize);
// Result: 2.0 — scale 2× by width

// Child already covers the parent
Size parent = Size(100, 100);
Size child = Size(200, 100);  // Wider child
double scale = fastCoverScanScale(parent, child);
// Result: 1.0 — no scale; child already covers

// Scale by height
Size parent = Size(100, 100);
Size child = Size(100, 50);   // Taller relative aspect
double scale = fastCoverScanScale(parent, child);
// Result: 2.0 — scale 2× by height
```

#### How it works

1. **Compare aspect ratios** — width ÷ height for parent and child  
2. **Pick a scale axis**  
   - If parent aspect ratio ≥ child aspect ratio: scale by width  
   - If parent aspect ratio < child aspect ratio: scale by height  
3. **Edge cases** — e.g. zero width or height  

#### Use cases

- **Images** — fill the container without distortion  
- **Video players** — fit content to arbitrary player sizes  
- **Backgrounds** — full-bleed backgrounds  
- **Responsive layout** — adapt content across screen sizes  

#### Example

```dart
// Image adaptation
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
        // Original image size (assumed known here)
        Size imageSize = Size(800, 600); // In practice, read from the image
        Size containerSize = Size(containerWidth, containerHeight);
        
        // Adapted size
        Size adaptedSize = fastCoverScanSize(containerSize, imageSize);
        
        // Or scale factor only
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
