import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/analytics_theme.dart';

/// Paginated enterprise data table — rows supplied dynamically from API data.
class AnalyticsEnterpriseTable extends StatefulWidget {
  final List<String> columns;
  final List<AnalyticsTableRow> rows;
  final List<AnalyticsTableRow>? pinnedRows;
  final int pageSize;
  final bool mobile;
  final List<double>? columnFlex;
  final String recordLabel;

  const AnalyticsEnterpriseTable({
    super.key,
    required this.columns,
    required this.rows,
    this.pinnedRows,
    this.pageSize = 10,
    this.mobile = false,
    this.columnFlex,
    this.recordLabel = 'records',
  });

  @override
  State<AnalyticsEnterpriseTable> createState() =>
      _AnalyticsEnterpriseTableState();
}

class _AnalyticsEnterpriseTableState extends State<AnalyticsEnterpriseTable> {
  int _page = 0;
  late final ScrollController _bodyController;

  @override
  void initState() {
    super.initState();
    _bodyController = ScrollController();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnalyticsEnterpriseTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows.length != widget.rows.length) {
      _page = 0;
      if (_bodyController.hasClients) {
        _bodyController.jumpTo(0);
      }
    }
  }

  int get _totalPages =>
      widget.rows.isEmpty ? 1 : (widget.rows.length / widget.pageSize).ceil();

  List<AnalyticsTableRow> get _pageRows {
    final start = _page * widget.pageSize;
    if (start >= widget.rows.length) return [];
    final end = (start + widget.pageSize).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  List<double> get _flexWeights {
    if (widget.columnFlex != null &&
        widget.columnFlex!.length == widget.columns.length) {
      return widget.columnFlex!;
    }
    return List<double>.filled(widget.columns.length, 1);
  }

  int _flexAt(int index) =>
      (_flexWeights[index] * 10).round().clamp(1, 100);

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty &&
        (widget.pinnedRows == null || widget.pinnedRows!.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text(
            'No records for this selection',
            style: AnalyticsDesktopTheme.bodySm,
          ),
        ),
      );
    }

    final showPager = _totalPages > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderRow(),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: true,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: Scrollbar(
              controller: _bodyController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              child: ListView.separated(
                controller: _bodyController,
                padding: EdgeInsets.zero,
                shrinkWrap: false,
                physics: const ClampingScrollPhysics(),
                itemCount: _pageRows.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AnalyticsDesktopTheme.border,
                ),
                itemBuilder: (context, index) =>
                    _buildDataRow(_pageRows[index]),
              ),
            ),
          ),
        ),
        if (widget.pinnedRows != null && widget.pinnedRows!.isNotEmpty) ...[
          const Divider(height: 1, color: AnalyticsDesktopTheme.border),
          for (final row in widget.pinnedRows!) _buildDataRow(row),
        ],
        if (showPager || widget.rows.isNotEmpty) _buildFooter(showPager),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AnalyticsDesktopTheme.tableHeader,
        border: Border(bottom: BorderSide(color: AnalyticsDesktopTheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.columns.length; i++)
              Expanded(
                flex: _flexAt(i),
                child: Text(
                  widget.columns[i].toUpperCase(),
                  style: AnalyticsDesktopTheme.tableHeaderStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(AnalyticsTableRow row) {
    return ColoredBox(
      color: row.highlight
          ? AnalyticsDesktopTheme.tableHeader
          : AnalyticsDesktopTheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < row.cells.length; i++)
              Expanded(
                flex: _flexAt(i),
                child: row.cells[i],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool showPager) {
    return Container(
      decoration: const BoxDecoration(
        color: AnalyticsDesktopTheme.surface,
        border: Border(top: BorderSide(color: AnalyticsDesktopTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Showing ${_pageRows.length} of ${widget.rows.length} ${widget.recordLabel}',
            style: AnalyticsDesktopTheme.bodySm,
          ),
          const Spacer(),
          if (showPager) ...[
            _PagerButton(
              label: 'Previous',
              enabled: _page > 0,
              onTap: () => setState(() => _page -= 1),
            ),
            const SizedBox(width: 8),
            _PagerButton(
              label: 'Next',
              enabled: _page < _totalPages - 1,
              onTap: () => setState(() => _page += 1),
            ),
          ],
        ],
      ),
    );
  }
}

class AnalyticsTableRow {
  final List<Widget> cells;
  final bool highlight;

  const AnalyticsTableRow(this.cells, {this.highlight = false});
}

class _PagerButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PagerButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AnalyticsDesktopTheme.textMain,
        side: const BorderSide(color: AnalyticsDesktopTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        ),
      ),
      child: Text(label, style: AnalyticsDesktopTheme.tableCellStyle),
    );
  }
}

/// Status pill used in attendance tables.
class AnalyticsStatusPill extends StatelessWidget {
  final String status;
  final bool onLeave;

  const AnalyticsStatusPill({
    super.key,
    required this.status,
    this.onLeave = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    late Color fg;
    late Color bg;

    if (onLeave || normalized.contains('leave')) {
      fg = AnalyticsDesktopTheme.warning;
      bg = AnalyticsDesktopTheme.warningBg;
    } else if (normalized == 'absent') {
      fg = AnalyticsDesktopTheme.danger;
      bg = AnalyticsDesktopTheme.dangerBg;
    } else if (normalized == 'working') {
      fg = AnalyticsDesktopTheme.success;
      bg = AnalyticsDesktopTheme.successBg;
    } else if (normalized == 'logged_out' ||
        normalized == 'auto_logout' ||
        normalized.contains('logout')) {
      fg = AnalyticsDesktopTheme.info;
      bg = AnalyticsDesktopTheme.infoBg;
    } else {
      fg = AnalyticsDesktopTheme.textMuted;
      bg = AnalyticsDesktopTheme.neutralBg;
    }

    final label = (status.isEmpty ? (onLeave ? 'on_leave' : '—') : status)
        .replaceAll('_', ' ')
        .toUpperCase();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AnalyticsDesktopTheme.tableCellBold.copyWith(
            fontSize: 11,
            color: fg,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// Attendance: Name gets more space, status less.
const attendanceColumnFlex = [2.2, 1.3, 1.1, 1.1, 0.8, 1.1];

/// Weekly summary columns.
const summaryColumnFlex = [2.5, 1.2, 1.2];

/// Billing money columns.
const billingColumnFlex = [1.2, 0.9, 0.9, 1.5, 1.5, 1.5];
