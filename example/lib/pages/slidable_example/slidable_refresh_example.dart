import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

/// FastPagingList + horizontal FastSlidable.
class SlidableRefreshExample extends StatefulWidget {
  const SlidableRefreshExample({super.key});

  @override
  State<SlidableRefreshExample> createState() => _SlidableRefreshExampleState();
}

class _SlidableRefreshExampleState extends State<SlidableRefreshExample> {
  final FastRefreshController _refresh = FastRefreshController();
  final GlobalKey<FastPagingState<List<String>, String, FastPagingList<String>>>
      _listKey =
      GlobalKey<FastPagingState<List<String>, String, FastPagingList<String>>>();
  final List<String> _removed = <String>[];

  void _remove(String item) {
    _removed.add(item);
    final FastPagingState<List<String>, String, FastPagingList<String>>? state =
        _listKey.currentState;
    final List<String>? data = state?.data;
    if (state == null || data == null) {
      return;
    }
    state.replaceData(List<String>.of(data)..remove(item));
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  Future<FastPagingPage<String>> _fetchPage(int page) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final List<String> items = List<String>.generate(
      12,
      (int i) => 'Message ${(page - 1) * 12 + i + 1}',
    ).where((String item) => !_removed.contains(item)).toList();
    return FastPagingPage<String>(
      items: items,
      page: page,
      hasMore: page < 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slidable · Refresh')),
      body: FastSlidableGroup(
        child: FastPagingList<String>(
          key: _listKey,
          controller: _refresh,
          refreshOnStart: true,
          fetchPage: _fetchPage,
          itemBuilder: (BuildContext context, int index, String item) {
            return FastSlidable(
              key: ValueKey<String>(item),
              groupTag: 'inbox',
              endPane: FastSlidablePane(
                motion: FastSlidableMotion.scroll,
                dismiss: FastSlidableDismiss(
                  onDismissed: () {
                    _remove(item);
                    showToast('Removed $item');
                  },
                ),
                fullSwipe: const FastSlidableFullSwipe(),
                children: <Widget>[
                  FastSlidableAction(
                    onPressed: (_) => showToast('Archive $item'),
                    backgroundColor: const Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Archive',
                  ),
                  FastSlidableAction(
                    onPressed: (_) => _remove(item),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(item),
                subtitle: const Text('Pull to refresh · swipe to act'),
              ),
            );
          },
        ),
      ),
    );
  }
}
