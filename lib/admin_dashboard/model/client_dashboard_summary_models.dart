enum TriStateFilter { all, yes, no, pending }

class SummaryPagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const SummaryPagination({
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrev = false,
  });

  factory SummaryPagination.fromJson(Map<String, dynamic> json) {
    return SummaryPagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] == true,
      hasPrev: json['has_prev'] == true,
    );
  }

  int get rangeStart => total == 0 ? 0 : ((page - 1) * pageSize) + 1;

  int get rangeEnd {
    final end = page * pageSize;
    return end > total ? total : end;
  }
}

class ClientSummaryRow {
  final int paymentRecordId;
  final String clientName;
  final String email;
  final bool? invoiceSent;
  final bool? paymentReceived;
  final DateTime updatedAt;

  const ClientSummaryRow({
    required this.paymentRecordId,
    required this.clientName,
    required this.email,
    required this.invoiceSent,
    required this.paymentReceived,
    required this.updatedAt,
  });

  factory ClientSummaryRow.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v == 'null') return null;
      if (v == true || v == 'true') return true;
      if (v == false || v == 'false') return false;
      return null;
    }

    final updatedRaw = json['updated_at']?.toString();
    final updated = updatedRaw != null && updatedRaw.isNotEmpty
        ? (DateTime.tryParse(updatedRaw)?.toLocal() ?? DateTime.now())
        : DateTime.now();

    return ClientSummaryRow(
      paymentRecordId: json['payment_record_id'] ?? json['id'] ?? 0,
      clientName: _parseClientName(json),
      email: _parseEmail(json),
      invoiceSent: parseBool(json['invoice_sent']),
      paymentReceived: parseBool(json['payment_received']),
      updatedAt: updated,
    );
  }

  String get displayName {
    if (clientName.trim().isNotEmpty) return clientName.trim();
    if (email.trim().isNotEmpty) return email.trim();
    if (paymentRecordId > 0) return 'Client #$paymentRecordId';
    return 'Unknown client';
  }

  static String _parseClientName(Map<String, dynamic> json) {
    for (final key in ['client_name', 'name', 'full_name', 'company_name']) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final client = json['client'];
    if (client is Map) {
      final map = Map<String, dynamic>.from(client);
      for (final key in ['name', 'client_name', 'full_name']) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    } else if (client is String && client.trim().isNotEmpty) {
      return client.trim();
    }

    final details = json['client_details'];
    if (details is Map) {
      final map = Map<String, dynamic>.from(details);
      final value = map['name'] ?? map['client_name'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static String _parseEmail(Map<String, dynamic> json) {
    final direct = json['email'] ?? json['client_email'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    final client = json['client'];
    if (client is Map) {
      final value = client['email'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  ClientSummaryRow copyWith({
    String? clientName,
    String? email,
    bool? invoiceSent,
    bool? paymentReceived,
    DateTime? updatedAt,
  }) {
    return ClientSummaryRow(
      paymentRecordId: paymentRecordId,
      clientName: clientName ?? this.clientName,
      email: email ?? this.email,
      invoiceSent: invoiceSent ?? this.invoiceSent,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ClientDashboardSummary {
  final int totalClients;
  final int invoicesSentCount;
  final int invoicesPendingCount;
  final int paymentsReceivedCount;
  final int paymentsPendingCount;
  final List<ClientSummaryRow> results;
  final SummaryPagination pagination;

  const ClientDashboardSummary({
    this.totalClients = 0,
    this.invoicesSentCount = 0,
    this.invoicesPendingCount = 0,
    this.paymentsReceivedCount = 0,
    this.paymentsPendingCount = 0,
    this.results = const [],
    this.pagination = const SummaryPagination(),
  });

  factory ClientDashboardSummary.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    dynamic resultsRaw =
        root['results'] ?? root['clients'] ?? root['rows'] ?? root['items'] ?? [];

    if (resultsRaw is Map) {
      resultsRaw = resultsRaw['results'] ??
          resultsRaw['items'] ??
          resultsRaw['clients'] ??
          resultsRaw['rows'] ??
          [];
    }

    final rows = resultsRaw is List
        ? resultsRaw
            .map((e) => ClientSummaryRow.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <ClientSummaryRow>[];

    final paginationSource = root['pagination'] is Map
        ? Map<String, dynamic>.from(root['pagination'] as Map)
        : <String, dynamic>{};

    return ClientDashboardSummary(
      totalClients: root['total_clients'] ?? json['total_clients'] ?? 0,
      invoicesSentCount:
          root['invoices_sent_count'] ?? json['invoices_sent_count'] ?? 0,
      invoicesPendingCount:
          root['invoices_pending_count'] ?? json['invoices_pending_count'] ?? 0,
      paymentsReceivedCount:
          root['payments_received_count'] ?? json['payments_received_count'] ?? 0,
      paymentsPendingCount:
          root['payments_pending_count'] ?? json['payments_pending_count'] ?? 0,
      results: rows,
      pagination: SummaryPagination.fromJson(paginationSource),
    );
  }

  ClientDashboardSummary copyWith({
    int? totalClients,
    int? invoicesSentCount,
    int? invoicesPendingCount,
    int? paymentsReceivedCount,
    int? paymentsPendingCount,
    List<ClientSummaryRow>? results,
    SummaryPagination? pagination,
  }) {
    return ClientDashboardSummary(
      totalClients: totalClients ?? this.totalClients,
      invoicesSentCount: invoicesSentCount ?? this.invoicesSentCount,
      invoicesPendingCount: invoicesPendingCount ?? this.invoicesPendingCount,
      paymentsReceivedCount:
          paymentsReceivedCount ?? this.paymentsReceivedCount,
      paymentsPendingCount: paymentsPendingCount ?? this.paymentsPendingCount,
      results: results ?? this.results,
      pagination: pagination ?? this.pagination,
    );
  }

  String fingerprint() {
    final rows = results
        .map((r) =>
            '${r.paymentRecordId}:${r.invoiceSent}:${r.paymentReceived}:${r.updatedAt.millisecondsSinceEpoch}')
        .join('|');
    return '$totalClients|$invoicesSentCount|$invoicesPendingCount|'
        '$paymentsReceivedCount|$paymentsPendingCount|$rows';
  }
}

bool? cycleTriState(bool? current) {
  if (current == null) return true;
  if (current) return false;
  return null;
}
