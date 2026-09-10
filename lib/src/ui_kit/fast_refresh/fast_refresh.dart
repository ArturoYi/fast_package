/// FastRefresh：下拉刷新 / 上拉加载。
///
/// 对齐 EasyRefresh 核心物理与状态机，仅依赖 Flutter SDK。
/// 通过自定义 [ScrollPhysics] 处理越界摩擦与回弹，由 Header / Footer
/// notifier 驱动 `inactive → drag → armed → ready → processing →
/// processed → done`。
///
/// 分页列表用 [FastPagingList]（`fetchPage` + `itemBuilder`），或继承 [FastPaging]。
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' as physics;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

part 'fast_refresh_widget.dart';
part 'fast_refresh_physics.dart';
part 'fast_refresh_notifier.dart';
part 'fast_refresh_behavior.dart';
part 'fast_refresh_indicator.dart';
part 'fast_refresh_controller.dart';
part 'builder/fast_refresh_builder.dart';
part 'header/fast_refresh_header.dart';
part 'header/fast_header_locator.dart';
part 'footer/fast_refresh_footer.dart';
part 'footer/fast_footer_locator.dart';
part 'fast_refresh_theme.dart';
part 'widgets/fast_classic_indicator.dart';
part 'widgets/fast_classic_header.dart';
part 'widgets/fast_classic_footer.dart';
part 'widgets/fast_material_indicator.dart';
part 'fast_paging.dart';
part 'fast_paging_list.dart';
