/// Normalizes task status labels to API values: PENDING | IN_PROGRESS | COMPLETED.
String normalizeTaskStatusForApi(String status) {
  final normalized = status.trim().toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
  switch (normalized) {
    case 'PENDING':
      return 'PENDING';
    case 'IN_PROGRESS':
    case 'INPROGRESS':
      return 'IN_PROGRESS';
    case 'COMPLETED':
      return 'COMPLETED';
    default:
      return normalized;
  }
}

/// Display label for UI dropdowns.
String taskStatusDisplayLabel(String status) {
  switch (normalizeTaskStatusForApi(status)) {
    case 'IN_PROGRESS':
      return 'In Progress';
    case 'COMPLETED':
      return 'Completed';
    default:
      return 'Pending';
  }
}
