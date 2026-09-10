import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Two slide-to-unlock beams that share the same timing.
/// 两种滑动解锁贴法，共用同一套扫光时序。
///
/// Both travel the slider width in ~3 s, pause ~1.8 s, then loop. Highlight
/// only hits the chosen target (whole capsule vs hint text); the wallpaper
/// behind the control stays still.
/// 两者都沿滑块宽度约 3 秒扫过、停约 1.8 秒再循环。高光只打在所选目标上
/// （整条胶囊 / 提示文案）；控件背后的壁纸不动。
class ShimmerSlideHintExample extends StatefulWidget {
  const ShimmerSlideHintExample({super.key});

  @override
  State<ShimmerSlideHintExample> createState() =>
      _ShimmerSlideHintExampleState();
}

class _ShimmerSlideHintExampleState extends State<ShimmerSlideHintExample> {
  static const Duration _beamDuration = FastShimmerHighlight.defaultDuration;
  static const Duration _beamPause = FastShimmerHighlight.defaultPauseDuration;

  bool _resetOnUnlock = true;
  bool _enabled = true;
  int _unlockCount = 0;

  void _onUnlocked() {
    setState(() => _unlockCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String date = '${now.month} 月 ${now.day} 日';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shimmer · Slide unlock'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF1B2838),
              Color(0xFF0B0F14),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            children: <Widget>[
              const SizedBox(height: 36),
              Text(
                time,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  height: 1,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _unlockCount == 0
                    ? '同一套 3 秒扫过 + 1.8 秒停顿；高光不打在壁纸上'
                    : '已解锁 $_unlockCount 次',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 36),
              const _ModeCaption(
                title: '整条滑块区域',
                subtitle: '斜向柔光扫过金属胶囊，文案和滑钮叠在上面',
              ),
              const SizedBox(height: 10),
              FastShimmerSlideUnlock(
                key: const Key('lock-screen-unlock-area'),
                label: '滑动解锁',
                successLabel: '已解锁',
                highlight: FastShimmerSlideUnlockHighlight.area,
                enabled: _enabled,
                resetOnUnlock: _resetOnUnlock,
                duration: _beamDuration,
                pauseDuration: _beamPause,
                onUnlocked: _onUnlocked,
              ),
              const SizedBox(height: 22),
              const _ModeCaption(
                title: '仅文字高光',
                subtitle: '文案居中；光束只扫字形，轨道和滑钮不动',
              ),
              const SizedBox(height: 10),
              FastShimmerSlideUnlock(
                key: const Key('lock-screen-unlock-label'),
                label: '滑动解锁',
                successLabel: '已解锁',
                highlight: FastShimmerSlideUnlockHighlight.label,
                enabled: _enabled,
                resetOnUnlock: _resetOnUnlock,
                duration: _beamDuration,
                pauseDuration: _beamPause,
                onUnlocked: _onUnlocked,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '解锁后复位',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'resetOnUnlock',
                  style: TextStyle(color: Color(0x99FFFFFF)),
                ),
                value: _resetOnUnlock,
                onChanged: (bool value) {
                  setState(() => _resetOnUnlock = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '启用滑动',
                  style: TextStyle(color: Colors.white),
                ),
                value: _enabled,
                onChanged: (bool value) {
                  setState(() => _enabled = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCaption extends StatelessWidget {
  const _ModeCaption({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
