import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';
import 'package:my_app/event_management/features/events/data/datasources/user_directory_datasource.dart';

import '../../domain/entities/event.dart';

class _PickerColors {
  const _PickerColors({
    required this.background,
    required this.primary,
    required this.primaryLight,
    required this.textDark,
    required this.textMuted,
    required this.border,
    required this.cardBackground,
  });

  final Color background;
  final Color primary;
  final Color primaryLight;
  final Color textDark;
  final Color textMuted;
  final Color border;
  final Color cardBackground;

  factory _PickerColors.of(BuildContext context) {
    if (AdaptiveLayout.useMobileUi(context)) {
      return const _PickerColors(
        background: MobileEventTheme.background,
        primary: MobileEventTheme.terracotta,
        primaryLight: MobileEventTheme.selectedCell,
        textDark: MobileEventTheme.textDark,
        textMuted: MobileEventTheme.textMuted,
        border: MobileEventTheme.border,
        cardBackground: MobileEventTheme.card,
      );
    }
    return const _PickerColors(
      background: DashboardUiTheme.pageBackground,
      primary: DashboardUiTheme.primary,
      primaryLight: DashboardUiTheme.primaryLight,
      textDark: DashboardUiTheme.textDark,
      textMuted: DashboardUiTheme.textMuted,
      border: DashboardUiTheme.border,
      cardBackground: DashboardUiTheme.cardBackground,
    );
  }
}

/// Opens participant picker — dialog on desktop, bottom sheet on mobile.
Future<List<Participant>?> showParticipantPicker(
  BuildContext context, {
  required List<Participant> selected,
}) {
  if (AdaptiveLayout.useMobileUi(context)) {
    return showModalBottomSheet<List<Participant>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ParticipantPicker(selected: selected),
    );
  }

  return showDialog<List<Participant>>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: DashboardUiTheme.pageBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: ParticipantPicker(
          selected: selected,
          embedded: true,
        ),
      ),
    ),
  );
}

/// Loads paginated users from `GET /api/users/all/?search=&page=`.
class ParticipantPicker extends StatefulWidget {
  final List<Participant> selected;
  final bool embedded;

  const ParticipantPicker({
    required this.selected,
    this.embedded = false,
    super.key,
  });

  @override
  State<ParticipantPicker> createState() => _ParticipantPickerState();
}

class _ParticipantPickerState extends State<ParticipantPicker> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
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
    _scrollCtrl.dispose();
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
        msg = e.message ?? e.error?.toString() ?? 'Network error';
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

  void _done() => Navigator.pop(context, _selected);

  @override
  Widget build(BuildContext context) {
    final body = _ParticipantPickerBody(
      embedded: widget.embedded,
      searchCtrl: _searchCtrl,
      scrollCtrl: _scrollCtrl,
      selected: _selected,
      results: _results,
      loading: _loading,
      loadingMore: _loadingMore,
      error: _error,
      onSearchChanged: _onSearchChanged,
      onRemoveSelected: (i) => setState(() => _selected.removeAt(i)),
      onAddUser: _addUser,
      onLoadMore: _loadMore,
      onDone: _done,
    );

    if (widget.embedded) return body;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: true,
      builder: (_, sheetScroll) {
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
              _loadMore();
            }
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: _PickerColors.of(context).background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _ParticipantPickerBody(
              embedded: false,
              searchCtrl: _searchCtrl,
              scrollCtrl: sheetScroll,
              selected: _selected,
              results: _results,
              loading: _loading,
              loadingMore: _loadingMore,
              error: _error,
              onSearchChanged: _onSearchChanged,
              onRemoveSelected: (i) => setState(() => _selected.removeAt(i)),
              onAddUser: _addUser,
              onLoadMore: _loadMore,
              onDone: _done,
            ),
          ),
        );
      },
    );
  }
}

class _ParticipantPickerBody extends StatelessWidget {
  const _ParticipantPickerBody({
    required this.embedded,
    required this.searchCtrl,
    required this.scrollCtrl,
    required this.selected,
    required this.results,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.onSearchChanged,
    required this.onRemoveSelected,
    required this.onAddUser,
    required this.onLoadMore,
    required this.onDone,
  });

  final bool embedded;
  final TextEditingController searchCtrl;
  final ScrollController scrollCtrl;
  final List<Participant> selected;
  final List<DirectoryUser> results;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onRemoveSelected;
  final ValueChanged<DirectoryUser> onAddUser;
  final VoidCallback onLoadMore;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = _PickerColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add participants',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: c.textDark,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: c.textMuted,
                ),
              ],
            ),
          )
        else
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, embedded ? 8 : 0, 16, 0),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search people…',
              hintStyle: TextStyle(color: c.textMuted),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: c.primary,
              ),
              filled: true,
              fillColor: c.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: c.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: c.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selected (${selected.length})',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: c.textMuted,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: selected.isEmpty
              ? Center(
                  child: Text(
                    'Tap a user below to add',
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: selected.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final p = selected[i];
                    return Chip(
                      label: Text(p.username, maxLines: 1),
                      onDeleted: () => onRemoveSelected(i),
                      backgroundColor: c.primaryLight,
                      deleteIconColor: c.primary,
                      labelStyle: TextStyle(
                        color: c.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(
                          color: c.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Divider(
          height: 1,
          color: c.border.withValues(alpha: 0.7),
        ),
        if (error != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: SelectableText(
                    error!,
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (embedded &&
                  n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
                onLoadMore();
              }
              return false;
            },
            child: loading && results.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: c.primary,
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: results.length + (loadingMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= results.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: c.primary,
                            ),
                          ),
                        );
                      }
                      final u = results[i];
                      final already =
                          selected.any((p) => p.id == u.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: Material(
                          color: c.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: already ? null : () => onAddUser(u),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: already
                                      ? c.primary
                                          .withValues(alpha: 0.35)
                                      : c.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        c.primaryLight,
                                    child: Text(
                                      (u.username.isNotEmpty
                                              ? u.username.characters.first
                                              : '?')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: c.primary,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: c.textDark,
                                          ),
                                        ),
                                        if (u.email != null &&
                                            u.email!.isNotEmpty)
                                          Text(
                                            u.email!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: c.textMuted,
                                              fontWeight: FontWeight.w500,
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
                                        ? c.primary
                                        : c.textMuted,
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
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
  }
}
