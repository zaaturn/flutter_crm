import '../../../core/network/api_services.dart';
import 'package:my_app/client tracker/features/clients/models/dashboard_model.dart';
import '../../../core/constants/app_constant.dart';

class DashboardRepository {

  final ApiClient _api = ApiClient();

  Future<DashboardModel> getDashboard() async {

    final data = await _api.get(AppConstants.dashboard);

    return DashboardModel.fromJson(data);
  }
}