import 'package:flutter/painting.dart';

/// Calculates the optimal size for a child element to cover its parent container
/// 计算子元素覆盖父容器的最佳尺寸
///
/// This function implements a cover-fit algorithm similar to CSS's object-fit: cover.
/// It ensures the child element completely covers the parent container while maintaining aspect ratio.
/// 此函数实现了类似CSS中object-fit: cover的覆盖适配算法。
/// 确保子元素完全覆盖父容器，同时保持宽高比。
///
/// Algorithm steps:
/// 算法步骤：
/// 1. Check for edge cases with zero dimensions
///    检查包含零维度的边界情况
/// 2. Calculate aspect ratios of both parent and child
///    计算父容器和子元素的宽高比
/// 3. Compare aspect ratios to determine scaling direction
///    比较宽高比以确定缩放方向
/// 4. Scale the child element to cover the parent completely
///    缩放子元素以完全覆盖父容器
///
/// @param parentSize The size of the parent container (width x height)
///                   父容器尺寸 (宽 x 高)
/// @param childSize The original size of the child element (width x height)
///                  子元素原始尺寸 (宽 x 高)
/// @return The calculated size that covers the parent container while maintaining aspect ratio
///         计算得出的覆盖父容器的尺寸，保持原始宽高比
Size fastCoverScanSize(Size parentSize, Size childSize) {
  // Handle edge cases with zero dimensions
  // 处理包含零维度的边界情况
  // If any dimension is zero, return the original child size to avoid division by zero
  // 如果任何维度为零，返回原始子元素尺寸以避免除零错误
  if (parentSize.width == 0 || parentSize.height == 0 || childSize.width == 0 || childSize.height == 0) {
    return childSize;
  }

  // Calculate aspect ratios (width / height) for both parent and child
  // 计算父容器和子元素的宽高比 (宽度 / 高度)
  double parentAspectRatio = parentSize.width / parentSize.height;
  double childAspectRatio = childSize.width / childSize.height;

  // Compare aspect ratios to determine the scaling strategy
  // 比较宽高比以确定缩放策略
  if (parentAspectRatio >= childAspectRatio) {
    // Parent is wider (or same aspect ratio) compared to child
    // 父容器比子元素更宽（或宽高比相同）
    // Scale based on width to ensure full coverage
    // 基于宽度进行缩放以确保完全覆盖
    double scale = parentSize.width / childSize.width;
    return Size(childSize.width * scale, childSize.height * scale);
  } else {
    // Parent is taller compared to child
    // 父容器比子元素更高
    // Scale based on height to ensure full coverage
    // 基于高度进行缩放以确保完全覆盖
    double scale = parentSize.height / childSize.height;
    return Size(childSize.width * scale, childSize.height * scale);
  }
}

/// Get the scaling ratio for the child element to cover the parent container
/// 获取子元素覆盖父容器的缩放比例
///
/// This function calculates the scaling ratio needed to make the child element cover the parent container
/// while maintaining aspect ratio. It implements the same algorithm as fastCoverScanSize but returns
/// only the scaling factor instead of the calculated size.
/// 此函数计算子元素覆盖父容器的缩放比例，同时保持宽高比。它实现了与fastCoverScanSize相同的算法，
/// 但只返回缩放因子而不是计算后的尺寸。
///
/// Algorithm steps:
/// 算法步骤：
/// 1. Check for edge cases with zero dimensions
///    检查包含零维度的边界情况
/// 2. Check if parent and child have the same aspect ratio
///    检查父容器和子元素是否具有相同的宽高比
/// 3. Calculate aspect ratios of both parent and child
///    计算父容器和子元素的宽高比
/// 4. Compare aspect ratios to determine scaling direction
///    比较宽高比以确定缩放方向
/// 5. Return the appropriate scaling ratio
///    返回相应的缩放比例
///
/// Scaling logic:
/// 缩放逻辑：
/// - If parent aspect ratio >= child aspect ratio: scale by width
///   如果父容器宽高比 >= 子元素宽高比：按宽度缩放
/// - If parent aspect ratio < child aspect ratio: scale by height
///   如果父容器宽高比 < 子元素宽高比：按高度缩放
/// - If aspect ratios are equal: return 1.0 (no scaling needed)
///   如果宽高比相同：返回1.0（无需缩放）
///
/// @param parentSize The size of the parent container (width x height)
///                   父容器尺寸 (宽 x 高)
/// @param childSize The original size of the child element (width x height)
///                  子元素原始尺寸 (宽 x 高)
/// @return The scaling ratio needed to make the child element cover the parent container
///         子元素覆盖父容器的缩放比例
///         - Returns 1.0 if any dimension is zero or aspect ratios are equal
///           如果任何维度为零或宽高比相同则返回1.0
///         - Returns width scale ratio if parent is wider relative to child
///           如果父容器相对于子元素更宽则返回宽度缩放比例
///         - Returns height scale ratio if parent is taller relative to child
///           如果父容器相对于子元素更高则返回高度缩放比例
///
/// Examples:
/// 示例：
/// ```dart
/// // Parent: 100x100, Child: 50x50 -> scale = 2.0 (width scale)
/// double scale = fastCoverScanScale(Size(100, 100), Size(50, 50));
/// 
/// // Parent: 100x100, Child: 200x100 -> scale = 1.0 (no scaling needed)
/// double scale = fastCoverScanScale(Size(100, 100), Size(200, 100));
/// 
/// // Parent: 100x100, Child: 50x200 -> scale = 2.0 (width scale)
/// double scale = fastCoverScanScale(Size(100, 100), Size(50, 200));
/// 
/// // Parent: 100x100, Child: 200x50 -> scale = 2.0 (height scale)
/// double scale = fastCoverScanScale(Size(100, 100), Size(200, 50));
/// ```
double fastCoverScanScale(Size parentSize, Size childSize) {
  // 处理包含零维度的边界情况
  if (parentSize.width == 0 || parentSize.height == 0 || childSize.width == 0 || childSize.height == 0) {
    return 1.0;
  }
  
  // 计算父容器和子元素的宽高比 (宽度 / 高度)
  double parentAspectRatio = parentSize.width / parentSize.height;
  double childAspectRatio = childSize.width / childSize.height;
  
  // 比较宽高比以确定缩放策略
  if (parentAspectRatio >= childAspectRatio) {
    // 父容器比子元素更宽（或宽高比相同），按宽度缩放
    return parentSize.width / childSize.width;
  } else {
    // 父容器比子元素更高，按高度缩放
    return parentSize.height / childSize.height;
  }
}
