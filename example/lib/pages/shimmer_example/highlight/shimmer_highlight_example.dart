import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Decorative shimmer on real text and icons — not skeleton bars.
/// 真实文字 / 图标上的装饰性扫光，不是骨架横条。
class ShimmerHighlightExample extends StatefulWidget {
  const ShimmerHighlightExample({super.key});

  @override
  State<ShimmerHighlightExample> createState() =>
      _ShimmerHighlightExampleState();
}

class _ShimmerHighlightExampleState extends State<ShimmerHighlightExample> {
  FastShimmerDirection _direction = FastShimmerDirection.leftToRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer · Highlight')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'FastShimmerText 画的是骨架横条；FastShimmerHighlight 用细白光束扫真实字形（默认 3 秒扫过、1.8 秒停顿）。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Direction',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButton<FastShimmerDirection>(
            value: _direction,
            isExpanded: true,
            items: FastShimmerDirection.values
                .map(
                  (FastShimmerDirection d) => DropdownMenuItem(
                    value: d,
                    child: Text(d.name),
                  ),
                )
                .toList(),
            onChanged: (FastShimmerDirection? value) {
              if (value == null) return;
              setState(() => _direction = value);
            },
          ),
          const SizedBox(height: 20),
          const _SectionTitle('金色字标'),
          const SizedBox(height: 12),
          Center(
            child: FastShimmerHighlight.text(
              'FAST PACKAGE',
              textAlign: TextAlign.center,
              direction: _direction,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.4,
                color: Color(0xFFC9A227),
              ),
              highlightColor: const Color(0xFFFFF4C2),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle('图标扫光'),
          const SizedBox(height: 12),
          _IconRow(direction: _direction),
          const SizedBox(height: 28),
          const _SectionTitle('按钮文案'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {},
            child: FastShimmerHighlight.text(
              '立即开通',
              direction: _direction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              highlightColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: FastShimmerHighlight.text(
              '查看会员权益',
              direction: _direction,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              highlightColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.direction});

  final FastShimmerDirection direction;

  @override
  Widget build(BuildContext context) {
    const Color base = Color(0xFF9E9E9E);
    const Color highlight = Color(0xFFFFFFFF);

    Widget icon(IconData data) {
      return FastShimmerHighlight(
        direction: direction,
        baseColor: base,
        highlightColor: highlight,
        child: Icon(data, size: 32, color: Colors.white),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        icon(Icons.chevron_right),
        icon(Icons.play_arrow_rounded),
        icon(Icons.star_rounded),
        icon(Icons.notifications_rounded),
      ],
    );
  }
}
