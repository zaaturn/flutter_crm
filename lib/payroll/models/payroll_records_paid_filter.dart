/// `GET /api/payroll/records/` paid filter (not legacy `status=`).
enum PayrollRecordsPaidFilter {
  /// Omit `paid` — all rows for period.
  all,

  /// `paid=true`
  paid,

  /// `paid=false`
  unpaid,

  /// `paid=unset`
  unset,
}
