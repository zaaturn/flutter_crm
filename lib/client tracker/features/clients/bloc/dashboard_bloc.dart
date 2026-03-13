import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../repository/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;

  DashboardBloc(this.repo) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_loadDashboard);
  }

  Future<void> _loadDashboard(
      LoadDashboardEvent event,
      Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    try {
      final data = await repo.getDashboard();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}