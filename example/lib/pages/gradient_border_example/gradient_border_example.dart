import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class GradientBorderExample extends StatefulWidget {
  const GradientBorderExample({super.key});

  @override
  State<GradientBorderExample> createState() => _GradientBorderExampleState();
}

class _GradientBorderExampleState extends State<GradientBorderExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GradientBorderExample"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
            ),
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                border: GradientBoxBorders(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
