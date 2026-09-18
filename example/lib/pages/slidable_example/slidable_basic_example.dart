import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Motions and start / end panes.
class SlidableBasicExample extends StatefulWidget {
  const SlidableBasicExample({super.key});

  @override
  State<SlidableBasicExample> createState() => _SlidableBasicExampleState();
}

class _SlidableBasicExampleState extends State<SlidableBasicExample> {
  FastSlidableMotion _motion = FastSlidableMotion.scroll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slidable · Basic')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: FastSlidableMotion.values.map((FastSlidableMotion m) {
                return ChoiceChip(
                  label: Text(m.name),
                  selected: _motion == m,
                  onSelected: (_) => setState(() => _motion = m),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FastSlidableGroup(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (BuildContext context, int index) {
                  return FastSlidable(
                    groupTag: 'basic',
                    startPane: FastSlidablePane(
                      motion: _motion,
                      children: <Widget>[
                        FastSlidableAction(
                          onPressed: (_) => showToast('Share $index'),
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.share,
                          label: 'Share',
                        ),
                      ],
                    ),
                    endPane: FastSlidablePane(
                      motion: _motion,
                      children: <Widget>[
                        FastSlidableAction(
                          onPressed: (_) => showToast('More $index'),
                          backgroundColor: const Color(0xFF0392CF),
                          foregroundColor: Colors.white,
                          icon: Icons.more_horiz,
                          label: 'More',
                        ),
                        FastSlidableAction(
                          onPressed: (_) => showToast('Delete $index'),
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text('Inbox item $index'),
                      subtitle: Text('Motion: ${_motion.name}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
