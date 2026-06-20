import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import 'package:my_app/services/api_client.dart';

import 'package:my_app/tasks/models/crm_task.dart';
import 'package:my_app/tasks/task_status_utils.dart';

class CrmTaskApiService {
  final ApiClient _api = ApiClient();

  String get _base => '${_api.baseEmployee}/tasks';

  Future<CrmTask> getTask(int id) async {
    final data = await _api.get('$_base/$id/');
    return CrmTask.fromJson(data);
  }

  Future<CrmTask> updateTask(
    int id,
    Map<String, dynamic> fields, {
    PlatformFile? attachment,
  }) async {
    final payload = Map<String, dynamic>.from(fields)
      ..removeWhere((_, v) => v == null);

    if (attachment != null &&
        (attachment.bytes != null || attachment.path != null)) {
      final map = <String, dynamic>{...payload};
      if (attachment.bytes != null) {
        map['attachment'] = MultipartFile.fromBytes(
          attachment.bytes!,
          filename: attachment.name,
        );
      } else {
        map['attachment'] = await MultipartFile.fromFile(
          attachment.path!,
          filename: attachment.name,
        );
      }
      final response = await _api.dio.patch(
        '$_base/$id/',
        data: FormData.fromMap(map),
      );
      return CrmTask.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    final data = await _api.patch('$_base/$id/', body: payload);
    return CrmTask.fromJson(data);
  }

  Future<CrmTask> updateTaskStatus(int id, String status) async {
    final data = await _api.post(
      '$_base/$id/status/',
      body: {'status': normalizeTaskStatusForApi(status)},
    );
    return CrmTask.fromJson(data);
  }
}
