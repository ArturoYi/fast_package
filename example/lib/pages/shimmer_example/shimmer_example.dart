import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Complete demo for explicit shimmer skeletons.
/// 显式 shimmer 骨架的完整演示页。
class ShimmerExample extends StatefulWidget {
  const ShimmerExample({super.key});

  @override
  State<ShimmerExample> createState() => _ShimmerExampleState();
}

class _ShimmerExampleState extends State<ShimmerExample> {
  bool _isLoading = true;
  FastShimmerDirection _direction = FastShimmerDirection.leftToRight;
  bool _useDarkShimmer = false;

  FastShimmerTheme get _previewTheme {
    final FastShimmerTheme base =
        _useDarkShimmer ? FastShimmerTheme.dark : FastShimmerTheme.light;
    return base.copyWith(direction: _direction);
  }

  Future<void> _simulateLoad() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shimmer Example'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _simulateLoad,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('isLoading'),
            subtitle: Text(_isLoading ? 'Showing skeleton' : 'Showing content'),
            value: _isLoading,
            onChanged: (bool value) => setState(() => _isLoading = value),
          ),
          SwitchListTile(
            title: const Text('Dark shimmer theme'),
            value: _useDarkShimmer,
            onChanged: (bool value) => setState(() => _useDarkShimmer = value),
          ),
          const SizedBox(height: 8),
          const Text('Direction', style: TextStyle(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 24),
          Theme(
            data: Theme.of(context).copyWith(
              extensions: <ThemeExtension<dynamic>>[_previewTheme],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FastShimmer(
                  isLoading: _isLoading,
                  skeleton: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Profile card'),
                      SizedBox(height: 12),
                      _ProfileSkeleton(),
                      SizedBox(height: 28),
                      _SectionTitle('List'),
                      SizedBox(height: 12),
                      FastShimmerList(itemCount: 4),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Profile card'),
                      SizedBox(height: 12),
                      _ProfileContent(),
                      SizedBox(height: 28),
                      _SectionTitle('List'),
                      SizedBox(height: 12),
                      _FeedListContent(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Color contrast (light vs dark theme)'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeSwatch(
                        label: 'Light',
                        theme: FastShimmerTheme.light.copyWith(
                          direction: _direction,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeSwatch(
                        label: 'Dark',
                        theme: FastShimmerTheme.dark.copyWith(
                          direction: _direction,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateLoad,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Simulate load'),
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

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FastShimmerBox(
          width: double.infinity,
          height: 160,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            FastShimmerCircle(diameter: 56),
            SizedBox(width: 12),
            Expanded(
              child: FastShimmerText(lines: 2, width: 180),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FastShimmerBox(
          width: double.infinity,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        FastShimmerBox(
          width: 220,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 160,
            color: Colors.indigo.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.landscape, size: 56, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(Icons.person)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex Chen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text('Flutter engineer · Shanghai'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Building fast UI kits with explicit shimmer skeletons and shared animation scopes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _FeedListContent extends StatelessWidget {
  const _FeedListContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(4, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Feed item ${index + 1}'),
            subtitle: const Text('Loaded content row'),
          ),
        );
      }),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.label,
    required this.theme,
  });

  final String label;
  final FastShimmerTheme theme;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: <ThemeExtension<dynamic>>[theme],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const FastShimmerScope(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FastShimmerBox(width: double.infinity, height: 18),
                    SizedBox(height: 8),
                    FastShimmerText(lines: 2, width: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
