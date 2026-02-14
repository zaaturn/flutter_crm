// lib/utils/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';

import 'package:my_app/services/api_client.dart';


final GetIt sl = GetIt.instance;

void setupServiceLocator() {

  sl.registerLazySingleton<ApiClient>(() => ApiClient());


  sl.registerLazySingleton<IEmployeeRepository>(
        () => EmployeeRepository(apiClient: sl<ApiClient>()),
  );
}