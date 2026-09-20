import 'dart:math' as math;

import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// Header 二楼演示：拉过刷新阈值继续拉，打开接近全屏的第二页。
///
/// 用 [FastSecondaryBuilderHeader] 包 Classic Header（locator），
/// [FastRefresh.clipBehavior] 为 [Clip.none]。二楼页是纯色，不要 Rive。
class RefreshSecondaryExample extends StatefulWidget {
  const RefreshSecondaryExample({super.key});

  @override
  State<RefreshSecondaryExample> createState() => _RefreshSecondaryExampleState();
}

class _RefreshSecondaryExampleState extends State<RefreshSecondaryExample> {
  final FastRefreshController _controller = FastRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  final ScrollController _scrollController = ScrollController();
  final FastRefreshStateListenable _listenable = FastRefreshStateListenable();

  List<String> _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');
  int _page = 1;
  bool _callOpenSecondary = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    setState(() {
      _page = 1;
      _items = List<String>.generate(20, (int i) => 'Item ${i + 1}');
    });
    _controller
      ..finishRefresh()
      ..resetFooter();
  }

  Future<void> _onLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }
    if (_page >= 3) {
      _controller.finishLoad(FastRefreshResult.noMore);
      return;
    }
    setState(() {
      _page += 1;
      final int start = _items.length;
      _items = <String>[
        ..._items,
        ...List<String>.generate(10, (int i) => 'Item ${start + i + 1}'),
      ];
    });
    _controller.finishLoad();
  }

  double _scaleFor(FastRefreshIndicatorState state) {
    if (state.offset <= state.actualTriggerOffset) {
      return 1;
    }
    final double secondary = state.actualSecondaryTriggerOffset!;
    return math.max(
      0.0,
      (secondary - state.offset) / (secondary - state.actualTriggerOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final Color appBarBackground = theme.appBarTheme.backgroundColor ??
        theme.colorScheme.surface;
    final double secondaryDimension =
        size.height - kToolbarHeight - mediaQuery.padding.top;

    return Scaffold(
      body: FastRefresh(
        clipBehavior: Clip.none,
        controller: _controller,
        scrollController: _scrollController,
        header: FastSecondaryBuilderHeader(
          header: const FastClassicHeader(
            position: FastRefreshIndicatorPosition.locator,
            clipBehavior: Clip.none,
            safeArea: false,
            mainAxisAlignment: MainAxisAlignment.end,
            dragText: '下拉刷新',
            armedText: '释放刷新',
            readyText: '正在刷新...',
            processingText: '正在刷新...',
            processedText: '刷新成功',
            failedText: '刷新失败',
            messageText: '上次更新 %T',
          ),
          secondaryTriggerOffset: 120,
          secondaryDimension: secondaryDimension,
          listenable: _listenable,
          builder: (
            BuildContext context,
            FastRefreshIndicatorState state,
            FastRefreshIndicator header,
          ) {
            final FastRefreshMode mode = state.mode;
            final double scale = _scaleFor(state);
            final bool secondaryForeground =
                mode == FastRefreshMode.secondaryOpen ||
                    mode == FastRefreshMode.secondaryClosing;
            Widget secondaryPage = Opacity(
              opacity: 1 - scale,
              child: ColoredBox(
                color: theme.colorScheme.primaryContainer,
                child: Center(
                  child: Text(
                    '二楼',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            );
            if (secondaryForeground) {
              secondaryPage = PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, Object? result) {
                  if (didPop) {
                    return;
                  }
                  _controller.closeHeaderSecondary();
                },
                child: secondaryPage,
              );
            }
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  height: state.offset,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: size.height,
                    width: double.infinity,
                    child: secondaryPage,
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: mode == FastRefreshMode.secondaryArmed &&
                              !_callOpenSecondary
                          ? 1
                          : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '松开打开二楼',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: (mode == FastRefreshMode.secondaryReady ||
                          mode == FastRefreshMode.secondaryOpen ||
                          mode == FastRefreshMode.secondaryClosing)
                      ? 0
                      : scale,
                  child: header.build(context, state),
                ),
              ],
            );
          },
        ),
        footer: const FastClassicFooter(
          dragText: '上拉加载',
          armedText: '释放加载',
          readyText: '正在加载...',
          processingText: '正在加载...',
          processedText: '加载成功',
          noMoreText: '没有更多了',
          failedText: '加载失败',
          messageText: '上次更新 %T',
        ),
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            ValueListenableBuilder<FastRefreshIndicatorState?>(
              valueListenable: _listenable,
              builder: (
                BuildContext context,
                FastRefreshIndicatorState? state,
                Widget? child,
              ) {
                final FastRefreshMode? mode = state?.mode;
                final bool isSecondaryForeground =
                    mode == FastRefreshMode.secondaryOpen ||
                        mode == FastRefreshMode.secondaryClosing;
                final double scale = state == null ? 1 : _scaleFor(state);
                return SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: !isSecondaryForeground,
                  leading: isSecondaryForeground
                      ? BackButton(
                          onPressed: _controller.closeHeaderSecondary,
                        )
                      : null,
                  backgroundColor: Color.lerp(
                    Colors.transparent,
                    appBarBackground,
                    scale,
                  ),
                  surfaceTintColor: Colors.transparent,
                  title: Opacity(
                    opacity: scale,
                    child: const Text('Refresh · 二楼'),
                  ),
                  actions: <Widget>[
                    if (!isSecondaryForeground)
                      Opacity(
                        opacity: scale,
                        child: IconButton(
                          tooltip: '打开二楼',
                          onPressed: () async {
                            _callOpenSecondary = true;
                            await _controller.openHeaderSecondary(
                              scrollController: _scrollController,
                            );
                            _callOpenSecondary = false;
                          },
                          icon: const Icon(Icons.layers_outlined),
                        ),
                      ),
                  ],
                );
              },
            ),
            const FastHeaderLocator.sliver(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(_items[index]),
                        subtitle: Text('page $_page · 继续下拉打开二楼'),
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
                childCount: _items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
