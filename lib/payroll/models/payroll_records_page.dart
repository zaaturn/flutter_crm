import 'payroll_record_model.dart';

class PayrollRecordsPage {
  const PayrollRecordsPage({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  final List<PayrollRecordModel> results;
  final int count;
  final String? next;
  final String? previous;

  factory PayrollRecordsPage.fromJson(dynamic data) {
    if (data is List) {
      final list = data
          .map(
            (e) => PayrollRecordModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      return PayrollRecordsPage(
        results: list,
        count: list.length,
        next: null,
        previous: null,
      );
    }

    final map = Map<String, dynamic>.from(data as Map);
    final raw = map['results'] ?? map['data'];
    final list = (raw is List) ? raw : const [];
    final results = list
        .map(
          (e) => PayrollRecordModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    return PayrollRecordsPage(
      results: results,
      count: (map['count'] as num?)?.toInt() ?? results.length,
      next: map['next']?.toString(),
      previous: map['previous']?.toString(),
    );
  }
}
