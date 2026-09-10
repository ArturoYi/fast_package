part of 'fast_refresh.dart';

/// [FastPagingList.fetchPage] 的一页结果。
class FastPagingPage<T> {
  /// 创建一页数据。
  const FastPagingPage({
    required this.items,
    required this.page,
    this.total,
    this.totalPage,
    this.hasMore,
  });

  /// 本页条目。
  final List<T> items;

  /// 当前页码。
  final int page;

  /// 全部条目数。优先于 [totalPage] 判断没有更多。
  final int? total;

  /// 总页数。
  final int? totalPage;

  /// 显式是否还有更多。非 `null` 时优先于 [total] / [totalPage] / 空页。
  final bool? hasMore;
}

/// 拉取第 [page] 页。
typedef FastPagingFetch<T> = Future<FastPagingPage<T>> Function(int page);

/// 不用继承的分页列表：传入 [fetchPage] 与 [itemBuilder] 即可。
///
/// 复杂 data 结构仍用 [FastPaging] 子类。
class FastPagingList<T> extends FastPaging<List<T>, T> {
  /// 创建分页列表。
  const FastPagingList({
    super.key,
    required this.fetchPage,
    required FastPagingItemBuilder<T> itemBuilder,
    this.firstPage = 1,
    this.header,
    this.footer,
    this.enableRefresh = true,
    this.enableLoad = true,
    super.useDefaultPhysics,
    super.controller,
    super.spring,
    super.frictionFactor,
    super.notRefreshHeader,
    super.notLoadFooter,
    super.simultaneously,
    super.canRefreshAfterNoMore,
    super.canLoadAfterNoMore,
    super.resetAfterRefresh,
    super.refreshOnStart,
    super.callRefreshOverOffset,
    super.callLoadOverOffset,
    super.fit,
    super.clipBehavior,
    super.scrollBehaviorBuilder,
    super.scrollController,
    super.triggerAxis,
    super.isNested,
    super.refreshOnStartWidgetBuilder,
    super.emptyWidgetBuilder,
  })  : assert(firstPage > 0, 'firstPage must be greater than 0.'),
        super(itemBuilder: itemBuilder);

  /// 按页拉取。刷新请求 [firstPage]，加载请求下一页。
  final FastPagingFetch<T> fetchPage;

  /// 第一页页码，默认 1。
  final int firstPage;

  /// 可选 Header。未传时用 [FastRefresh.defaultHeaderBuilder]。
  final FastRefreshHeader? header;

  /// 可选 Footer。未传时用 [FastRefresh.defaultFooterBuilder]。
  final FastRefreshFooter? footer;

  /// 是否启用下拉刷新。
  final bool enableRefresh;

  /// 是否启用上拉 / 触底加载。
  final bool enableLoad;

  @override
  FastPagingState<List<T>, T, FastPagingList<T>> createState() =>
      _FastPagingListState<T>();
}

class _FastPagingListState<T>
    extends FastPagingState<List<T>, T, FastPagingList<T>> {
  int? _page;
  int? _total;
  int? _totalPage;
  bool? _hasMore;
  bool _lastPageEmpty = false;

  @override
  int? get page => _page;

  @override
  int? get total => _total;

  @override
  int? get totalPage => _totalPage;

  @override
  int get count => data?.length ?? 0;

  @override
  T getItem(int index) => data![index];

  @override
  bool get enableRefresh => widget.enableRefresh;

  @override
  bool get enableLoad => widget.enableLoad;

  @override
  bool get isNoMore {
    if (data == null) {
      return false;
    }
    if (_hasMore != null) {
      return !_hasMore!;
    }
    if (total != null || (page != null && totalPage != null)) {
      return super.isNoMore;
    }
    return _lastPageEmpty;
  }

  @override
  FastRefreshHeader buildHeader() => widget.header ?? super.buildHeader();

  @override
  FastRefreshFooter buildFooter() => widget.footer ?? super.buildFooter();

  @override
  Widget buildItem(BuildContext context, int index, T item) {
    return buildItemByBuilder(context, index, item);
  }

  void _applyPage(FastPagingPage<T> pageData, {required bool append}) {
    setState(() {
      if (append) {
        data = <T>[...?data, ...pageData.items];
      } else {
        data = pageData.items;
      }
      _page = pageData.page;
      _total = pageData.total;
      _totalPage = pageData.totalPage;
      _hasMore = pageData.hasMore;
      _lastPageEmpty = pageData.items.isEmpty;
    });
  }

  @override
  Future<FastRefreshResult?> onRefresh() async {
    final FastPagingPage<T> pageData = await widget.fetchPage(widget.firstPage);
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    _applyPage(pageData, append: false);
    return null;
  }

  @override
  Future<FastRefreshResult?> onLoad() async {
    final int next = (page ?? widget.firstPage) + 1;
    final FastPagingPage<T> pageData = await widget.fetchPage(next);
    if (!mounted) {
      return FastRefreshResult.fail;
    }
    _applyPage(pageData, append: true);
    return null;
  }
}
