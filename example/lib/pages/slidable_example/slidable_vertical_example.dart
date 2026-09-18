import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Vertical slidable.
class SlidableVerticalExample extends StatelessWidget {
  const SlidableVerticalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slidable · Vertical')),
      body: Center(
        child: SizedBox(
          width: 280,
          height: 180,
          child: FastSlidable(
            direction: Axis.vertical,
            startPane: FastSlidablePane(
              motion: FastSlidableMotion.scroll,
              extentRatio: 0.35,
              children: <Widget>[
                FastSlidableAction(
                  onPressed: (_) => showToast('Up'),
                  backgroundColor: const Color(0xFF21B7CA),
                  foregroundColor: Colors.white,
                  icon: Icons.arrow_upward,
                  label: 'Up',
                ),
              ],
            ),
            endPane: FastSlidablePane(
              motion: FastSlidableMotion.scroll,
              extentRatio: 0.35,
              children: <Widget>[
                FastSlidableAction(
                  onPressed: (_) => showToast('Down'),
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.arrow_downward,
                  label: 'Down',
                ),
              ],
            ),
            child: const Card(
              child: Center(child: Text('Drag vertically')),
            ),
          ),
        ),
      ),
    );
  }
}
