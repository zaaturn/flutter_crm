import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/client tracker/features/payment/model/payment_model.dart';

class AdminClientSummaryPanel extends StatelessWidget {
  /// When true (sidebar Client Billing screen), each zone gets its own panel
  /// on the mint canvas. When false (main dashboard embed), uses the compact
  /// single-box layout inside the parent panel.
  final bool separatePanels;

  const AdminClientSummaryPanel({
    super.key,
    this.separatePanels = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientDashboardSummaryCubit, ClientDashboardSummaryState>(
      listenWhen: (prev, next) => prev.toastError != next.toastError,
      listener: (context, state) {
        final msg = state.toastError;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: const Color(0xFFC62828)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.summary.results.isEmpty) {
          if (separatePanels) {
            return const AdminDashboardPanel(
              child: Center(
                child: CircularProgressIndicator(color: AdminDashboardTheme.teal),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AdminDashboardTheme.teal),
          );
        }

        if (state.error != null && state.summary.results.isEmpty) {
          final error = _ErrorView(
            message: state.error!,
            onRetry: () => context.read<ClientDashboardSummaryCubit>().load(),
          );
          if (separatePanels) {
            return AdminDashboardPanel(child: error);
          }
          return error;
        }

        final total = state.summary.totalClients;

        if (separatePanels) {
          return _SeparatePanelsBody(
            state: state,
            total: total,
          );
        }

        return _EmbeddedBody(state: state, total: total);
      },
    );
  }
}

/// Compact layout used inside the main dashboard's single client panel.
class _EmbeddedBody extends StatelessWidget {
  final ClientDashboardSummaryState state;
  final int total;

  const _EmbeddedBody({required this.state, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderRow(state: state),
          const SizedBox(height: 10),
          _StatRow(
            summary: state.summary,
            total: total,
            separatePanels: false,
          ),
          const SizedBox(height: 10),
          _FilterRow(state: state),
          const SizedBox(height: 8),
          Expanded(
            child: state.summary.results.isEmpty
                ? _EmptyClients(month: state.month, year: state.year)
                : _ClientSlider(rows: state.summary.results),
          ),
          const SizedBox(height: 6),
          _PaginationBar(state: state),
        ],
      ),
    );
  }
}

/// Analytics-style layout — separate panel per zone (sidebar Client Billing).
class _SeparatePanelsBody extends StatelessWidget {
  final ClientDashboardSummaryState state;
  final int total;

  const _SeparatePanelsBody({required this.state, required this.total});

  @override
  Widget build(BuildContext context) {
    const gap = AdminDashboardTheme.panelGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderRow(state: state),
        const SizedBox(height: gap),
        _StatRow(
          summary: state.summary,
          total: total,
          separatePanels: true,
        ),
        const SizedBox(height: gap),
        AdminDashboardPanel(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _FilterRow(state: state),
          ),
        ),
        const SizedBox(height: gap),
        Expanded(
          child: AdminDashboardPanel(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: state.summary.results.isEmpty
                        ? _EmptyClients(
                            month: state.month,
                            year: state.year,
                          )
                        : _ClientSlider(rows: state.summary.results),
                  ),
                  _PaginationBar(state: state),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final ClientDashboardSummaryState state;

  const _HeaderRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientDashboardSummaryCubit>();

    return Row(
      children: [
        Text(
          'Clients',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AdminDashboardTheme.textDark,
          ),
        ),
        if (state.isSilentRefreshing) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
        const Spacer(),
        _MiniDropdown<int>(
          value: state.month,
          width: 96,
          items: List.generate(12, (i) {
            final m = i + 1;
            return DropdownMenuItem(
              value: m,
              child: Text(
                monthNames[m].substring(0, 3),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }),
          onChanged: (v) {
            if (v != null) cubit.setMonth(v);
          },
        ),
        const SizedBox(width: 6),
        _MiniDropdown<int>(
          value: state.year,
          width: 72,
          items: List.generate(5, (i) {
            final y = 2024 + i;
            return DropdownMenuItem(
              value: y,
              child: Text('$y', style: const TextStyle(fontSize: 12)),
            );
          }),
          onChanged: (v) {
            if (v != null) cubit.setYear(v);
          },
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final ClientDashboardSummary summary;
  final int total;
  final bool separatePanels;

  const _StatRow({
    required this.summary,
    required this.total,
    required this.separatePanels,
  });

  @override
  Widget build(BuildContext context) {
    final stats = <({String label, String value, Color color})>[
      (label: 'Total', value: '$total', color: const Color(0xFF1976D2)),
      (
        label: 'Inv Sent',
        value: '${summary.invoicesSentCount} / $total',
        color: const Color(0xFF2E7D32),
      ),
      (
        label: 'Inv Pend',
        value: '${summary.invoicesPendingCount} / $total',
        color: const Color(0xFFF57F17),
      ),
      (
        label: 'Paid',
        value: '${summary.paymentsReceivedCount} / $total',
        color: const Color(0xFF2E7D32),
      ),
    ];

    if (!separatePanels) {
      return Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _MiniStatCard(
                label: stats[i].label,
                value: stats[i].value,
                color: stats[i].color,
                separatePanels: false,
              ),
            ),
          ],
        ],
      );
    }

    const gap = AdminDashboardTheme.panelGap;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++)
            Expanded(
              child: AdminDashboardPanel(
                margin: i < stats.length - 1
                    ? const EdgeInsets.only(right: gap)
                    : null,
                child: _MiniStatCard(
                  label: stats[i].label,
                  value: stats[i].value,
                  color: stats[i].color,
                  separatePanels: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool separatePanels;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.separatePanels = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: separatePanels ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: separatePanels ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          separatePanels ? AdminDashboardTheme.panelRadius - 4 : 10,
        ),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            separatePanels ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AdminDashboardTheme.textDark,
            ),
          ),
        ],
      ),
    );

    if (!separatePanels) return card;
    return Padding(padding: const EdgeInsets.all(10), child: card);
  }
}

class _FilterRow extends StatelessWidget {
  final ClientDashboardSummaryState state;

  const _FilterRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientDashboardSummaryCubit>();

    return Row(
      children: [
        Expanded(
          child: _MiniDropdown<TriStateFilter>(
            value: state.invoiceFilter,
            hint: 'Invoice',
            items: const [
              DropdownMenuItem(value: TriStateFilter.all, child: Text('All Inv', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.yes, child: Text('Sent', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.no, child: Text('Not Sent', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.pending, child: Text('Pending', style: TextStyle(fontSize: 11))),
            ],
            onChanged: (v) {
              if (v != null) cubit.setInvoiceFilter(v);
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MiniDropdown<TriStateFilter>(
            value: state.paymentFilter,
            hint: 'Payment',
            items: const [
              DropdownMenuItem(value: TriStateFilter.all, child: Text('All Pay', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.yes, child: Text('Received', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.no, child: Text('Not Rcvd', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: TriStateFilter.pending, child: Text('Pending', style: TextStyle(fontSize: 11))),
            ],
            onChanged: (v) {
              if (v != null) cubit.setPaymentFilter(v);
            },
          ),
        ),
      ],
    );
  }
}

class _ClientSlider extends StatelessWidget {
  final List<ClientSummaryRow> rows;

  const _ClientSlider({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final row = rows[index];
        return _ClientRowCard(row: row, index: index);
      },
    );
  }
}

class _ClientRowCard extends StatelessWidget {
  final ClientSummaryRow row;
  final int index;

  const _ClientRowCard({
    required this.row,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hoverText =
        '${row.displayName}\n${row.email.isNotEmpty ? '${row.email}\n' : ''}'
        'Invoice: ${_statusLabel(row.invoiceSent, true)}\n'
        'Payment: ${_statusLabel(row.paymentReceived, false)}\n'
        'Updated: ${formatRelativeTime(row.updatedAt)}\n'
        '${_formatDateTime(row.updatedAt)}';

    return Tooltip(
      message: hoverText,
      waitDuration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AdminDashboardTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminDashboardTheme.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${row.displayName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdminDashboardTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _StatusBadge(
                  value: row.invoiceSent,
                  isInvoice: true,
                ),
                const SizedBox(width: 4),
                _StatusBadge(
                  value: row.paymentReceived,
                  isInvoice: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool? value;
  final bool isInvoice;

  const _StatusBadge({
    required this.value,
    required this.isInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(value, isInvoice);
    final color = _statusColor(value);

    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (value == true) Icon(Icons.check_rounded, size: 11, color: color),
          if (value == true) const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final ClientDashboardSummaryState state;

  const _PaginationBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientDashboardSummaryCubit>();
    final p = state.summary.pagination;

    return Row(
      children: [
        Expanded(
          child: Text(
            p.total == 0
                ? 'No clients'
                : 'Showing ${p.rangeStart}-${p.rangeEnd} of ${p.total}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AdminDashboardTheme.textMuted,
            ),
          ),
        ),
        _MiniDropdown<int>(
          value: state.pageSize,
          width: 58,
          items: const [
            DropdownMenuItem(value: 10, child: Text('10', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(value: 20, child: Text('20', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(value: 50, child: Text('50', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(value: 100, child: Text('100', style: TextStyle(fontSize: 11))),
          ],
          onChanged: (v) {
            if (v != null) cubit.setPageSize(v);
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: p.hasPrev ? () => cubit.setPage(p.page - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${p.page}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          onPressed: p.hasNext ? () => cubit.setPage(p.page + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _MiniDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double? width;
  final String? hint;

  const _MiniDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AdminDashboardTheme.iconRailBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminDashboardTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: hint != null ? Text(hint!, style: const TextStyle(fontSize: 11)) : null,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, color: AdminDashboardTheme.textDark),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ),
      ),
    );
  }
}

class _EmptyClients extends StatelessWidget {
  final int month;
  final int year;

  const _EmptyClients({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No clients for ${monthNames[month]} $year',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AdminDashboardTheme.textMuted,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AdminDashboardTheme.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(bool? value, bool isInvoice) {
  if (value == null) return 'Pending';
  if (value) return isInvoice ? 'Sent' : 'Received';
  return isInvoice ? 'Not Sent' : 'Not Rcvd';
}

Color _statusColor(bool? value) {
  if (value == null) return const Color(0xFF757575);
  if (value) return const Color(0xFF2E7D32);
  return const Color(0xFFC62828);
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '${monthNames[local.month]} ${local.day}, ${local.year} $h:$m';
}

String formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) {
    final n = diff.inMinutes;
    return '$n minute${n == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    final n = diff.inHours;
    return '$n hour${n == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    final n = diff.inDays;
    return '$n day${n == 1 ? '' : 's'} ago';
  }
  return _formatDateTime(dt);
}
