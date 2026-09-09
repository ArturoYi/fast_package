import 'package:example/routes/routes.dart';
import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: rootNavigatorKey,
      routes: ExampleRoute.routes,
      initialRoute: ExampleRoute.initRoutes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return FastLoadingOverlay(
          navigatorKey: rootNavigatorKey,
          child: FastToastOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
