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
    final rawList = await remote.getUsers(
      department: department,
      designation: designation,
      search: search,
    );

    return rawList
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<DepartmentModel>> getDepartments({String? search}) async {
    final list = await remote.getDepartments(search: search);

    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);

      return DepartmentModel(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
        name: map['name'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<List<DesignationModel>> getDesignations({String? search}) async {
    final list = await remote.getDesignations(search: search);

    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);

      return DesignationModel(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
        name: map['name'] as String? ?? '',
      );
    }).toList();
  }
}
