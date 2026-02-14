
import 'employee.dart';

class PaginatedResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Employee> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List? ?? [])
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: results,
    );
  }

  bool get hasMore => next != null;
}