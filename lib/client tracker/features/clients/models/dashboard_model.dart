class DashboardModel {
  final int totalClients;
  final int activeServices;
  final int invoicesSent;
  final int paymentsReceived;
  final List<dynamic> recentClients;

  DashboardModel({
    required this.totalClients,
    required this.activeServices,
    required this.invoicesSent,
    required this.paymentsReceived,
    required this.recentClients,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalClients: json['total_clients'] ?? 0,
      activeServices: json['active_services'] ?? 0,
      invoicesSent: json['invoices_sent'] ?? 0,
      paymentsReceived: json['payments_received'] ?? 0,
      recentClients: json['recent_clients'] ?? [],
    );
  }
}