import '../../domain/models/user_entity.dart';
import '../../domain/models/department_model.dart';
import '../../domain/models/designation_model.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  Future<List<UserEntity>> getUsers({
    String? department,
    String? designation,
    String? search,
  }) async {
    final response = await remote.getUsers(
      department: department,
      designation: designation,
      search: search,
    );

    final results = response is Map && response.containsKey('results')
        ? response['results']
        : response;

    return (results as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DepartmentModel>> getDepartments({String? search}) async { // ← NEW
    final response = await remote.getDepartments(search: search);

    final list = response is Map && response.containsKey('results')
        ? response['results'] as List
        : response as List;

    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return DepartmentModel(e['name']?.toString() ?? e.toString());
      }
      return DepartmentModel(e.toString());
    }).toList();
  }

  @override
  Future<List<DesignationModel>> getDesignations({String? search}) async { // ← NEW
    final response = await remote.getDesignations(search: search);

    final list = response is Map && response.containsKey('results')
        ? response['results'] as List
        : response as List;

    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return DesignationModel(e['name']?.toString() ?? e.toString());
      }
      return DesignationModel(e.toString());
    }).toList();
  }
}