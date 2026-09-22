import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// How the list is hosted.
/// 列表挂在哪种容器上。
enum DemoScroll {
  /// Own [CustomScrollView] (`FastAnimatedList` / `.grid`).
  /// 自己占一个滚动视图。
  box,

  /// Caller-owned [CustomScrollView] sliver.
  /// 嵌进外层 [CustomScrollView]。
  sliver,

  /// `shrinkWrap` inside [SingleChildScrollView] / [Column].
  /// 缩进 [Column] / [SingleChildScrollView]。
  column,
}

/// Row vs cell.
/// 一行还是一格。
enum DemoCells {
  /// Vertical list.
  /// 纵向列表。
  list,

  /// 2-column grid.
  /// 两列网格。
  grid,
}

/// Which public list entry to build.
/// 用哪一个对外入口。
enum DemoListMode {
  /// [FastAnimatedList] only.
  /// 只做增删。
  mutations,

  /// [FastReorderableList] only.
  /// 只做拖拽。
  reorder,

  /// [FastAnimatedReorderableList].
  /// 增删 + 拖拽。
  both,
}

/// One demo row / cell.
/// 示例里的一行 / 一格。
class DemoItem {
  /// Creates an item.
  /// 创建一项。
  const DemoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  /// Stable identity.
  /// 稳定 identity。
  final int id;

  /// Title.
  /// 标题。
  final String title;

  /// Supporting line.
  /// 辅助文案。
  final String subtitle;

  /// Small category chip.
  /// 分类标签。
  final String tag;

  /// Accent derived from [id].
  /// 由 [id] 决定的强调色。
  Color accent(ColorScheme scheme) {
    final List<Color> palette = <Color>[
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      const Color(0xFF0F766E),
      const Color(0xFFB45309),
      const Color(0xFF7C3AED),
    ];
    return palette[id % palette.length];
  }
}

const List<String> _kTitles = <String>[
  '整理收件箱',
  '设计走查',
  '接口联调',
  '写本周周报',
  '修复启动闪退',
  '发布预览包',
  '代码评审',
  '同步排期',
  '补齐单测',
  '更新文档',
  '整理待办',
  '体验走查',
];

const List<String> _kTags = <String>['产品', '设计', '开发', '测试', '发布'];

const List<String> _kNotes = <String>[
  '今天完成',
  '待确认',
  '进行中',
  '阻塞中',
  '可发布',
];

/// Creates a new item for [id].
/// 用 [id] 生成一项。
DemoItem demoItemFor(int id) {
  return DemoItem(
    id: id,
    title: _kTitles[id % _kTitles.length],
    subtitle: '${_kNotes[id % _kNotes.length]} · #$id',
    tag: _kTags[id % _kTags.length],
  );
}

/// In-memory catalog used by every scene.
/// 各场景共用的内存数据。
class DemoCatalog {
  /// Creates a catalog with [count] seed items.
  /// 用 [count] 条种子数据创建。
  DemoCatalog({int count = 8}) {
    reset(count: count);
  }

  /// Visible items. Mutated in place; callers [State.setState].
  /// 当前列表。就地修改；调用方 [State.setState]。
  final List<DemoItem> items = <DemoItem>[];

  int _nextId = 0;

  /// Next unused id.
  /// 下一个未用 id。
  int get nextId => _nextId;

  /// Replace with a fresh page of [count] items.
  /// 整表换成新的 [count] 条。
  void reset({int count = 8}) {
    items
      ..clear()
      ..addAll(
        List<DemoItem>.generate(count, (int i) => demoItemFor(_nextId + i)),
      );
    _nextId += count;
  }

  /// Insert one item at [index] (default: top).
  /// 在 [index] 插入一条（默认顶部）。
  DemoItem insertOne({int index = 0}) {
    final DemoItem item = demoItemFor(_nextId++);
    items.insert(index.clamp(0, items.length), item);
    return item;
  }

  /// Append [count] items (load-more / batch insert).
  /// 末尾追加 [count] 条（上拉加载 / 批量插入）。
  List<DemoItem> insertBatch(int count) {
    final List<DemoItem> added = List<DemoItem>.generate(
      count,
      (int i) => demoItemFor(_nextId + i),
    );
    _nextId += count;
    items.addAll(added);
    return added;
  }

  /// Remove [item] if present.
  /// 删除 [item]。
  void remove(DemoItem item) {
    items.removeWhere((DemoItem e) => e.id == item.id);
  }

  /// Remove up to [count] items from the end.
  /// 从末尾删掉最多 [count] 条。
  void removeBatch(int count) {
    final int n = count.clamp(0, items.length);
    if (n == 0) {
      return;
    }
    items.removeRange(items.length - n, items.length);
  }

  /// Flutter-style reorder (`newIndex -= 1` when `oldIndex < newIndex`).
  /// 对齐 Flutter 的排序。
  void reorder(int from, int to) {
    if (from < to) {
      to -= 1;
    }
    items.insert(to, items.removeAt(from));
  }
}

/// Shared grid spec for every scene.
/// 各场景共用的网格规格。
const SliverGridDelegateWithFixedCrossAxisCount kDemoGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 0.92,
);

/// Two-axis layout switcher: host × cells.
/// 两轴布局切换：容器 × 单元。
class DemoLayoutBar extends StatelessWidget {
  /// Creates the switcher.
  /// 创建切换条。
  const DemoLayoutBar({
    super.key,
    required this.scroll,
    required this.cells,
    required this.onScroll,
    required this.onCells,
  });

  /// Host.
  /// 容器。
  final DemoScroll scroll;

  /// Cells.
  /// 单元。
  final DemoCells cells;

  /// Host changed.
  /// 容器变化。
  final ValueChanged<DemoScroll> onScroll;

  /// Cells changed.
  /// 单元变化。
  final ValueChanged<DemoCells> onCells;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '容器',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            SegmentedButton<DemoScroll>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<DemoScroll>>[
                ButtonSegment<DemoScroll>(
                  value: DemoScroll.box,
                  label: Text('List'),
                  icon: Icon(Icons.view_agenda_outlined, size: 16),
                ),
                ButtonSegment<DemoScroll>(
                  value: DemoScroll.sliver,
                  label: Text('Sliver'),
                  icon: Icon(Icons.view_stream_outlined, size: 16),
                ),
                ButtonSegment<DemoScroll>(
                  value: DemoScroll.column,
                  label: Text('Column'),
                  icon: Icon(Icons.view_day_outlined, size: 16),
                ),
              ],
              selected: <DemoScroll>{scroll},
              onSelectionChanged: (Set<DemoScroll> next) {
                onScroll(next.first);
              },
            ),
            const SizedBox(height: 10),
            Text(
              '排列',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            SegmentedButton<DemoCells>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<DemoCells>>[
                ButtonSegment<DemoCells>(
                  value: DemoCells.list,
                  label: Text('列表'),
                  icon: Icon(Icons.list_outlined, size: 16),
                ),
                ButtonSegment<DemoCells>(
                  value: DemoCells.grid,
                  label: Text('网格'),
                  icon: Icon(Icons.grid_view_outlined, size: 16),
                ),
              ],
              selected: <DemoCells>{cells},
              onSelectionChanged: (Set<DemoCells> next) {
                onCells(next.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal chip toolbar.
/// 横向操作条。
class DemoToolbar extends StatelessWidget {
  /// Creates the toolbar.
  /// 创建工具条。
  const DemoToolbar({super.key, required this.children});

  /// Action chips / buttons.
  /// 操作。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Long-press vs handle.
/// 长按整行还是手柄。
class DemoDragTriggerBar extends StatelessWidget {
  /// Creates the trigger switcher.
  /// 创建触发方式切换。
  const DemoDragTriggerBar({
    super.key,
    required this.trigger,
    required this.onChanged,
  });

  /// Current trigger.
  /// 当前触发方式。
  final FastListDragTrigger trigger;

  /// Trigger changed.
  /// 触发方式变化。
  final ValueChanged<FastListDragTrigger> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SegmentedButton<FastListDragTrigger>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<FastListDragTrigger>>[
          ButtonSegment<FastListDragTrigger>(
            value: FastListDragTrigger.longPress,
            label: Text('长按整行'),
            icon: Icon(Icons.touch_app_outlined, size: 16),
          ),
          ButtonSegment<FastListDragTrigger>(
            value: FastListDragTrigger.handle,
            label: Text('手柄拖拽'),
            icon: Icon(Icons.drag_indicator, size: 16),
          ),
        ],
        selected: <FastListDragTrigger>{trigger},
        onSelectionChanged: (Set<FastListDragTrigger> next) {
          onChanged(next.first);
        },
      ),
    );
  }
}

/// Caption under the switcher.
/// 切换条下面的说明。
class DemoCaption extends StatelessWidget {
  /// Creates the caption.
  /// 创建说明。
  const DemoCaption({super.key, required this.text});

  /// Copy.
  /// 文案。
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
      ),
    );
  }
}

/// Colored header used by Sliver / Column hosts.
/// Sliver / Column 顶部的彩色说明。
class DemoHeroBanner extends StatelessWidget {
  /// Creates the banner.
  /// 创建横幅。
  const DemoHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  /// Title.
  /// 标题。
  final String title;

  /// Subtitle.
  /// 副标题。
  final String subtitle;

  /// Item count.
  /// 条数。
  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              scheme.primaryContainer,
              scheme.tertiaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List row.
/// 列表行。
class DemoItemTile extends StatelessWidget {
  /// Creates a row.
  /// 创建一行。
  const DemoItemTile({
    super.key,
    required this.item,
    required this.index,
    this.showHandle = false,
    this.onDelete,
  });

  /// Item.
  /// 数据。
  final DemoItem item;

  /// Visible index.
  /// 可见下标。
  final int index;

  /// Whether to show [FastListDragHandle].
  /// 是否显示手柄。
  final bool showHandle;

  /// Optional delete.
  /// 可选删除。
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = item.accent(scheme);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
          child: Row(
            children: <Widget>[
              if (showHandle) ...<Widget>[
                FastListDragHandle(
                  child: _HandleWell(color: scheme.surfaceContainerHighest),
                ),
                const SizedBox(width: 8),
              ],
              _AccentAvatar(index: index, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TagChip(label: item.tag, color: accent),
              if (onDelete != null)
                IconButton(
                  tooltip: '删除',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid cell.
/// 网格格。
class DemoItemCard extends StatelessWidget {
  /// Creates a cell.
  /// 创建一格。
  const DemoItemCard({
    super.key,
    required this.item,
    required this.index,
    this.showHandle = false,
    this.onDelete,
  });

  /// Item.
  /// 数据。
  final DemoItem item;

  /// Visible index.
  /// 可见下标。
  final int index;

  /// Whether to show [FastListDragHandle].
  /// 是否显示手柄。
  final bool showHandle;

  /// Optional delete.
  /// 可选删除。
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = item.accent(scheme);
    return Material(
      color: accent.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _AccentAvatar(index: index, color: accent, radius: 20),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (showHandle)
            Positioned(
              top: 6,
              right: 6,
              child: FastListDragHandle(
                child: _HandleWell(
                  color: scheme.surface.withValues(alpha: 0.9),
                  compact: true,
                ),
              ),
            ),
          if (onDelete != null && !showHandle)
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                tooltip: '删除',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
          if (onDelete != null && showHandle)
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                tooltip: '删除',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps [child] in a horizontal [FastSlidable].
/// 给 [child] 套一层水平 [FastSlidable]。
Widget demoSlidable({
  required DemoItem item,
  required Widget child,
  required VoidCallback onDelete,
  VoidCallback? onArchive,
}) {
  return FastSlidable(
    key: ValueKey<int>(item.id),
    groupTag: 'animated-list-demo',
    startPane: FastSlidablePane(
      motion: FastSlidableMotion.scroll,
      children: <Widget>[
        FastSlidableAction(
          onPressed: (_) => onArchive?.call(),
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          icon: Icons.archive_outlined,
          label: '归档',
        ),
      ],
    ),
    endPane: FastSlidablePane(
      motion: FastSlidableMotion.scroll,
      dismiss: FastSlidableDismiss(onDismissed: onDelete),
      fullSwipe: const FastSlidableFullSwipe(threshold: 0.5),
      children: <Widget>[
        FastSlidableAction(
          onPressed: (_) => onDelete(),
          backgroundColor: const Color(0xFFFE4A49),
          foregroundColor: Colors.white,
          icon: Icons.delete_outline,
          label: '删除',
        ),
      ],
    ),
    child: child,
  );
}

/// Builds the list / grid / sliver / column host for a scene.
/// 按场景搭好 list / grid / sliver / column 宿主。
Widget buildDemoList({
  required DemoScroll scroll,
  required DemoCells cells,
  required DemoListMode mode,
  required List<DemoItem> items,
  required FastListItemBuilder<DemoItem> itemBuilder,
  FastListDragTrigger dragTrigger = FastListDragTrigger.longPress,
  ReorderCallback? onReorder,
  ScrollPhysics? physics,
  ScrollController? scrollController,
  Widget? header,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(16, 4, 16, 28),
  bool wrapHost = true,
}) {
  final bool isGrid = cells == DemoCells.grid;
  final FastListStagger stagger = isGrid
      ? const FastListStagger.grid(columnCount: 2)
      : const FastListStagger.list();
  final FastListEntrance entrance =
      isGrid ? FastListEntrance.scale : FastListEntrance.fadeSlide;

  Widget sliver({required bool asSliver}) {
    switch (mode) {
      case DemoListMode.mutations:
        if (asSliver) {
          return isGrid
              ? FastSliverAnimatedList<DemoItem>.grid(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  gridDelegate: kDemoGridDelegate,
                  stagger: stagger,
                  entrance: entrance,
                  padding: padding,
                )
              : FastSliverAnimatedList<DemoItem>(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  stagger: stagger,
                  entrance: entrance,
                  padding: padding,
                );
        }
        return isGrid
            ? FastAnimatedList<DemoItem>.grid(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                gridDelegate: kDemoGridDelegate,
                stagger: stagger,
                entrance: entrance,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              )
            : FastAnimatedList<DemoItem>(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                stagger: stagger,
                entrance: entrance,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              );
      case DemoListMode.reorder:
        if (asSliver) {
          return isGrid
              ? FastSliverReorderableList<DemoItem>.grid(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  onReorder: onReorder!,
                  gridDelegate: kDemoGridDelegate,
                  dragTrigger: dragTrigger,
                  padding: padding,
                )
              : FastSliverReorderableList<DemoItem>(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  onReorder: onReorder!,
                  dragTrigger: dragTrigger,
                  padding: padding,
                );
        }
        return isGrid
            ? FastReorderableList<DemoItem>.grid(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                onReorder: onReorder!,
                gridDelegate: kDemoGridDelegate,
                dragTrigger: dragTrigger,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              )
            : FastReorderableList<DemoItem>(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                onReorder: onReorder!,
                dragTrigger: dragTrigger,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              );
      case DemoListMode.both:
        if (asSliver) {
          return isGrid
              ? FastSliverAnimatedReorderableList<DemoItem>.grid(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  onReorder: onReorder!,
                  gridDelegate: kDemoGridDelegate,
                  stagger: stagger,
                  entrance: entrance,
                  dragTrigger: dragTrigger,
                  padding: padding,
                )
              : FastSliverAnimatedReorderableList<DemoItem>(
                  items: items,
                  itemId: (DemoItem e) => e.id,
                  itemBuilder: itemBuilder,
                  onReorder: onReorder!,
                  stagger: stagger,
                  entrance: entrance,
                  dragTrigger: dragTrigger,
                  padding: padding,
                );
        }
        return isGrid
            ? FastAnimatedReorderableList<DemoItem>.grid(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                onReorder: onReorder!,
                gridDelegate: kDemoGridDelegate,
                stagger: stagger,
                entrance: entrance,
                dragTrigger: dragTrigger,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              )
            : FastAnimatedReorderableList<DemoItem>(
                items: items,
                itemId: (DemoItem e) => e.id,
                itemBuilder: itemBuilder,
                onReorder: onReorder!,
                stagger: stagger,
                entrance: entrance,
                dragTrigger: dragTrigger,
                padding: padding,
                physics: scroll == DemoScroll.column
                    ? const NeverScrollableScrollPhysics()
                    : physics,
                scrollController:
                    scroll == DemoScroll.column ? null : scrollController,
                shrinkWrap: scroll == DemoScroll.column,
                primary: scroll == DemoScroll.column ? false : null,
              );
    }
  }

  if (!wrapHost) {
    return sliver(asSliver: false);
  }

  switch (scroll) {
    case DemoScroll.box:
      return sliver(asSliver: false);
    case DemoScroll.sliver:
      return CustomScrollView(
        physics: physics,
        controller: scrollController,
        slivers: <Widget>[
          if (header != null) SliverToBoxAdapter(child: header),
          sliver(asSliver: true),
        ],
      );
    case DemoScroll.column:
      return SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (header != null) header,
            sliver(asSliver: false),
          ],
        ),
      );
  }
}

/// Caption for the current host × cells pair.
/// 当前容器 × 单元组合的说明。
String demoLayoutCaption(DemoScroll scroll, DemoCells cells) {
  final String arrange = cells == DemoCells.grid ? '网格' : '列表';
  switch (scroll) {
    case DemoScroll.box:
      return cells == DemoCells.grid
          ? '独立滚动的 FastAnimatedList.grid / Reorderable.grid。'
          : '独立滚动的 FastAnimatedList / Reorderable。';
    case DemoScroll.sliver:
      return 'CustomScrollView + FastSliver*（$arrange），上面有 Banner。';
    case DemoScroll.column:
      return 'SingleChildScrollView + shrinkWrap $arrange，适合嵌在 Column 里。';
  }
}

class _AccentAvatar extends StatelessWidget {
  const _AccentAvatar({
    required this.index,
    required this.color,
    this.radius = 22,
  });

  final int index;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius > 18 ? 14 : 12,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _HandleWell extends StatelessWidget {
  const _HandleWell({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 32 : 36;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.drag_indicator,
          size: compact ? 18 : 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
