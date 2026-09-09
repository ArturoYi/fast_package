import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Demo page for [showLoading].
/// [showLoading] 演示页。
class LoadingExample extends StatelessWidget {
  const LoadingExample({super.key});

  static const Duration _demoDuration = Duration(seconds: 2);

  Future<void> _showThenDismiss({
    String? message,
    WidgetBuilder? builder,
    FastLoadingConfig? config,
  }) async {
    showLoading(message: message, builder: builder, config: config);
    await Future<void>.delayed(_demoDuration);
    FastLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Example'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _showThenDismiss(),
            child: const Text('showLoading · 2s'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showThenDismiss(message: '加载中...'),
            child: const Text('showLoading · message · 2s'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showLoading(
              message: '点遮罩关闭',
              config: const FastLoadingConfig(barrierDismissible: true),
            ),
            child: const Text('showLoading · barrierDismissible'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showThenDismiss(
              builder: (BuildContext context) {
                return const Material(
                  color: Colors.black87,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '自定义 Loading',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            child: const Text('showLoading · builder · 2s'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showThenDismiss(message: '请求中...'),
            child: const Text('模拟请求 2s 后关闭'),
          ),
          const SizedBox(height: 12),
          const ElevatedButton(
            onPressed: FastLoading.dismiss,
            child: Text('dismiss'),
          ),
        ],
      ),
    );
  }
}
