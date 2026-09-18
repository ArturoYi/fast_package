import 'dart:ui' as ui;

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:example/routes/routes.dart';
import 'package:example/web_device_preview_controls.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Host viewports at or above this shortest side get a framed device preview.
const double _kWebPreviewMinShortestSide = 600;

const DevicePreset _kDefaultWebPreset = DevicePresets.iPhone16;

/// Enable simulation on desktop/tablet web, including release gallery builds.
bool get _enableWebDevicePreview {
  if (!kIsWeb) {
    return false;
  }
  final ui.FlutterView? view = ui.PlatformDispatcher.instance.implicitView;
  if (view == null) {
    return true;
  }
  final double shortestSide =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortestSide >= _kWebPreviewMinShortestSide;
}

void main() {
  final bool enabled = _enableWebDevicePreview;
  if (enabled) {
    DevicePreviewBindingMixin.latchConfiguration(
      enabled: true,
      initialSimulation: _kDefaultWebPreset.resolve(),
    );
  }
  DevicePreview.enable(
    enabled: enabled,
    padding: enabled ? const EdgeInsets.all(16) : EdgeInsets.zero,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fast Package Example',
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: !_enableWebDevicePreview,
      scrollBehavior: const _AppScrollBehavior(),
      routes: ExampleRoute.routes,
      initialRoute: ExampleRoute.initRoutes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) {
        return Overlay.wrap(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FastLoadingOverlay(
                navigatorKey: rootNavigatorKey,
                child: FastToastOverlay(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              WebDevicePreviewControls(navigatorKey: rootNavigatorKey),
            ],
          ),
        );
      },
    );
  }
}

/// Lets a desktop pointer drag lists the same way a finger does.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
