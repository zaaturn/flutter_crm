import '../models/user_entity.dart';
import '../models/department_model.dart';
import '../models/designation_model.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers({
    String? department,
    String? designation,
    String? search,
  });

  Future<List<DepartmentModel>> getDepartments({
    String? search,
  });

  Future<List<DesignationModel>> getDesignations({
    String? search,
  });
}