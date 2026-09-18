import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Programmatic open / close.
class SlidableProgrammaticExample extends StatefulWidget {
  const SlidableProgrammaticExample({super.key});

  @override
  State<SlidableProgrammaticExample> createState() =>
      _SlidableProgrammaticExampleState();
}

class _SlidableProgrammaticExampleState
    extends State<SlidableProgrammaticExample>
    with SingleTickerProviderStateMixin {
  late final FastSlidableController _controller = FastSlidableController(this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slidable · Controller'),
        actions: <Widget>[
          IconButton(
            tooltip: 'openStart',
            onPressed: _controller.openStart,
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'openEnd',
            onPressed: _controller.openEnd,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'close',
            onPressed: _controller.close,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: FastSlidable(
          controller: _controller,
          startPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            children: <Widget>[
              FastSlidableAction(
                onPressed: (_) => showToast('Share'),
                backgroundColor: const Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: 'Share',
              ),
            ],
          ),
          endPane: FastSlidablePane(
            motion: FastSlidableMotion.behind,
            children: <Widget>[
              FastSlidableAction(
                onPressed: (_) => showToast('Save'),
                backgroundColor: const Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.save,
                label: 'Save',
              ),
            ],
          ),
          child: const Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: Text('Use the AppBar buttons'),
              subtitle: Text('openStart / openEnd / close'),
            ),
          ),
        ),
      ),
    );
  }
}
