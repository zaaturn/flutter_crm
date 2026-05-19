import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/data/datasources/user_directory_datasource.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../../domain/entities/event.dart';

/// Loads paginated users from `GET /api/users/all/?search=&page=`.
class ParticipantPicker extends StatefulWidget {
  final List<Participant> selected;

  const ParticipantPicker({required this.selected, super.key});

  @override
  State<ParticipantPicker> createState() => _ParticipantPickerState();
}

class _ParticipantPickerState extends State<ParticipantPicker> {
  final _searchCtrl = TextEditingController();
  final _datasource = UserDirectoryDatasource();

  late List<Participant> _selected;
  final List<DirectoryUser> _results = [];
  Timer? _debounce;
  bool _loading = false;
  bool _loadingMore = false;
  String _query = '';
  int _page = 1;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reload(reset: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload({required bool reset}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _results.clear();
        _error = null;
        _loading = true;
      });
    }

    try {
      final page = await _datasource.fetchPage(page: _page, search: _query);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _results
            ..clear()
            ..addAll(page.users);
        } else {
          _results.addAll(page.users);
        }
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      String msg;
      if (e is DioException) {
        msg = e.message ??
            e.error?.toString() ??
            'Network error';
      } else {
        msg = e.toString();
      }
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = msg;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      final page = await _datasource.fetchPage(page: _page, search: _query);
      if (!mounted) return;
      setState(() {
        _results.addAll(page.users);
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _page -= 1;
        _loadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = value.trim();
      _reload(reset: true);
    });
  }

  void _addUser(DirectoryUser u) {
    if (u.id.isEmpty) return;
    if (_selected.any((p) => p.id == u.id)) return;
    setState(() {
      _selected.add(Participant(id: u.id, username: u.username));
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFAF3E0);
    const terracotta = Color(0xFFC05E41);
    const cardBeige = Color(0xFFEADBC8);
    const textDark = Color(0xFF3E2723);
    const textMuted = Color(0xFF8D6E63);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      // Must be true so the sheet passes a bounded height to [Column] + [Expanded].
      expand: true,
      builder: (ctx, sheetScroll) {
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
              _loadMore();
            }
            return false;
          },
          child: Container(
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: terracotta.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search people…',
                      hintStyle: const TextStyle(color: textMuted),
                      prefixIcon: const Icon(Icons.search, color: terracotta),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.65),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected (${_selected.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: textMuted,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: _selected.isEmpty
                      ? const Center(
                          child: Text(
                            'Tap a user below to add',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _selected.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, i) {
                            final p = _selected[i];
                            return Chip(
                              label: Text(p.username, maxLines: 1),
                              onDeleted: () =>
                                  setState(() => _selected.removeAt(i)),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.65),
                              deleteIconColor: terracotta,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide(
                                  color: terracotta.withValues(alpha: 0.18),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                if (_error != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _loading && _results.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: sheetScroll,
                          itemCount: _results.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= _results.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final u = _results[i];
                            final already = _selected.any((p) => p.id == u.id);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Material(
                                color: cardBeige,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: already ? null : () => _addUser(u),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              Colors.white.withValues(alpha: 0.65),
                                          child: Text(
                                            (u.username.isNotEmpty
                                                    ? u.username.characters.first
                                                    : '?')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: terracotta,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u.username,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: textDark,
                                                ),
                                              ),
                                              if (u.email != null &&
                                                  u.email!.isNotEmpty)
                                                Text(
                                                  u.email!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: textMuted,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.5,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          already
                                              ? Icons.check_circle_rounded
                                              : Icons.add_circle_outline_rounded,
                                          color: already
                                              ? terracotta
                                              : textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: terracotta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, _selected),
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
