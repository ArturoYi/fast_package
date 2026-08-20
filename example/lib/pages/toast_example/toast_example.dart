import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Demo page for [showToast] and [showCustomToast].
/// [showToast] 与 [showCustomToast] 演示页。
class ToastExample extends StatelessWidget {
  const ToastExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast Example'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => showToast('保存成功'),
            child: const Text('showToast'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showToast(
              '顶部提示',
              config: const FastToastConfig(
                position: FastToastPosition.top,
              ),
            ),
            child: const Text('showToast · top'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showToast(
              '底部提示',
              config: const FastToastConfig(
                position: FastToastPosition.bottom,
                dismissible: true,
              ),
            ),
            child: const Text('showToast · bottom · dismissible'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showCustomToast(
              Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Text(
                        '自定义 Toast',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('showCustomToast'),
          ),
          const SizedBox(height: 12),
          const ElevatedButton(
            onPressed: FastToast.dismiss,
            child: Text('dismiss'),
          ),
          const SizedBox(height: 12),
          const ElevatedButton(
            onPressed: FastToast.dismissAll,
            child: Text('dismissAll'),
          ),
        ],
      ),
    );
  }
}
