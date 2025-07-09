import 'package:flutter/painting.dart';

/// Calculates the optimal size for a child element to cover its parent container
/// 计算子元素覆盖父容器的最佳尺寸
///
/// This function implements a cover-fit algorithm similar to CSS's object-fit: cover.
/// It ensures the child element completely covers the parent container while maintaining aspect ratio.
/// 此函数实现了类似CSS中object-fit: cover的覆盖适配算法。
/// 确保子元素完全覆盖父容器，同时保持宽高比。
///
/// @param parentSize The size of the parent container 父容器尺寸
/// @param childSize The original size of the child element 子元素原始尺寸
/// @return The calculated size that covers the parent container 计算得出的覆盖父容器的尺寸
Size fastCoverScanSize(Size parentSize, Size childSize) {
  // Handle edge cases with zero dimensions
  // 处理包含零维度的边界情况
  if (parentSize.width == 0 && parentSize.height == 0) {
    // If parent has zero dimensions, return child size as is
    // 如果父元素尺寸为零，直接返回子元素尺寸
    return childSize;
  }

  if (childSize.width == 0 && childSize.height == 0) {
    // If child has zero dimensions, return parent size
    // 如果子元素尺寸为零，返回父元素尺寸
    return parentSize;
  }

  // Handle cases where one dimension is zero
  // 处理单个维度为零的情况
  if (parentSize.width == 0 || parentSize.height == 0) {
    return childSize;
  }

  // Case 1: Child is larger than parent in both dimensions
  // 情况1：子元素在两个维度上都大于等于父元素
  // Return original child size as it already covers the parent
  // 返回子元素原始尺寸，因为它已经覆盖了父元素
  if (childSize.width >= parentSize.width &&
      childSize.height >= parentSize.height) {
    return childSize;
  }

  // Case 2: Try scaling by width first
  // 情况2：首先尝试按宽度缩放
  // This approach maintains aspect ratio while ensuring width matches parent
  // 这种方法保持宽高比，同时确保宽度匹配父元素
  if (childSize.width <= parentSize.width) {
    // Calculate scale factor based on width ratio
    // 根据宽度比例计算缩放因子
    double scaleChildWidthProportion = parentSize.width / childSize.width;
    // Apply the same scale factor to height to maintain aspect ratio
    // 对高度应用相同的缩放因子以保持宽高比
    double scaleChildHeight = childSize.height * scaleChildWidthProportion;

    // Check if scaled height is sufficient to cover parent height
    // 检查缩放后的高度是否足以覆盖父元素高度
    if (scaleChildHeight >= parentSize.height) {
      return Size(parentSize.width, scaleChildHeight);
    }
  }

  // Case 3: Width scaling didn't work, try scaling by height
  // 情况3：宽度缩放不合适，尝试按高度缩放
  // This is the fallback approach when width scaling results in insufficient height
  // 当宽度缩放导致高度不足时的备用方案
  if (childSize.height <= parentSize.height) {
    // Calculate scale factor based on height ratio
    // 根据高度比例计算缩放因子
    double scaleChildHeightProportion = parentSize.height / childSize.height;
    // Apply the same scale factor to width to maintain aspect ratio
    // 对宽度应用相同的缩放因子以保持宽高比
    double scaleChildWidth = childSize.width * scaleChildHeightProportion;

    // Check if scaled width is sufficient to cover parent width
    // 检查缩放后的宽度是否足以覆盖父元素宽度
    if (scaleChildWidth >= parentSize.width) {
      return Size(scaleChildWidth, parentSize.height);
    }
  }

  // Case 4: Fallback - return original child size
  // 情况4：兜底方案 - 返回子元素原始尺寸
  // This case should theoretically never occur with proper aspect ratio scaling
  // 在正确的宽高比缩放下，这种情况理论上不应该发生
  // However, it's included as a safety measure for edge cases
  // 但作为边界情况的安全措施被包含在内
  return childSize;
}
