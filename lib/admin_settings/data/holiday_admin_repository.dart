import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:my_app/services/api_client.dart';

class AdminHoliday {
  const AdminHoliday({
    required this.id,
    required this.date,
    required this.name,
    this.localName = '',
    this.day = '',
  });

  final int id;
  final DateTime date;
  final String name;
  final String localName;
  final String day;

  factory AdminHoliday.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'].toString());
    return AdminHoliday(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      date: DateTime(date.year, date.month, date.day),
      name: (json['name'] ?? '').toString(),
      localName: (json['local_name'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
    );
  }
}

class HolidayImportResult {
  const HolidayImportResult(this.raw);

  final Map<String, dynamic> raw;

  bool get dryRun => raw['dry_run'] == true;
  int get created => (raw['created'] as num?)?.toInt() ?? 0;
  int get updated => (raw['updated'] as num?)?.toInt() ?? 0;
  int get removed => (raw['removed'] as num?)?.toInt() ?? 0;
  int get validRows => (raw['valid_rows'] as num?)?.toInt() ?? 0;
  String get summary => (raw['detail'] ?? '').toString();

  List<({int line, String error})> get errors {
    final list = raw['errors'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => (line: (e['line'] as num?)?.toInt() ?? 0, error: '${e['error']}'))
        .toList();
  }

  List<AdminHoliday> get holidays {
    final list = raw['holidays'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => AdminHoliday.fromJson({...Map<String, dynamic>.from(e), 'id': 0}))
        .toList();
  }
}

/// Superadmin holiday management. A date saved here is a day off for
/// everyone: the 1 PM check-in reminder doesn't go out.
class HolidayAdminRepository {
  final ApiClient _api = ApiClient();

  String get _manage => '${_api.baseLeaves}/holidays/manage';

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Superadmin view (editable). Everyone else reads the public list.
  Future<List<AdminHoliday>> list(int year, {required bool manage}) async {
    final List raw;
    if (manage) {
      raw = await _api.getList('$_manage/', queryParameters: {'year': year});
    } else {
      final data = await _api.get(
        '${_api.baseLeaves}/holidays/',
        queryParameters: {'year': year},
      );
      raw = data['holidays'] is List ? data['holidays'] as List : const [];
    }
    return raw
        .whereType<Map>()
        .map((e) => AdminHoliday.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<AdminHoliday> create(DateTime date, String name, {String localName = ''}) async {
    final data = await _api.post('$_manage/', body: {
      'date': _iso(date),
      'name': name.trim(),
      'local_name': localName.trim(),
    });
    return AdminHoliday.fromJson(data);
  }

  Future<AdminHoliday> update(int id, {DateTime? date, String? name, String? localName}) async {
    final data = await _api.patch('$_manage/$id/', body: {
      if (date != null) 'date': _iso(date),
      if (name != null) 'name': name.trim(),
      if (localName != null) 'local_name': localName.trim(),
    });
    return AdminHoliday.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('$_manage/$id/');

  /// Upload a CSV with `date,name` columns. With [dryRun] nothing is saved —
  /// the result is a preview of what would change.
  Future<HolidayImportResult> importCsv(
    Uint8List bytes,
    String fileName, {
    bool dryRun = false,
    bool replaceYears = false,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'dry_run': dryRun ? 'true' : 'false',
      'replace_years': replaceYears ? 'true' : 'false',
    });
    final data = await _api.post('$_manage/import/', body: form);
    return HolidayImportResult(data);
  }
}
