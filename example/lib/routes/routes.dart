import 'package:example/pages/debounce_example/debounce_example.dart';
import 'package:example/pages/gradient_border_example/gradient_border_example.dart';
import 'package:example/pages/index/example_index.dart';
import 'package:example/pages/shimmer_example/shimmer_example.dart';
import 'package:example/pages/toast_example/toast_example.dart';
import 'package:flutter/cupertino.dart';

class ExampleRoute {
  ExampleRoute._();

  static String get initRoutes => index;

  static String index = '/';
  static String detail = '/detail';
  //防抖系列
  static String debounce = '/debounce';
  //overlay系列
  static String overlay = '/overlay';
  //dash
  static String dash = '/dash';
  //border
  static String border = '/border';
  //shimmer
  static String shimmer = '/shimmer';
  //toast
  static String toast = '/toast';

  static Map<String, Widget Function(BuildContext)> get routes => {
        index: (context) => ExampleIndex(),
        detail: (context) => const Placeholder(),
        debounce: (context) => const DebounceExample(),
        border: (context) => const GradientBorderExample(),
        shimmer: (context) => const ShimmerExample(),
        toast: (context) => const ToastExample(),
      };
}
