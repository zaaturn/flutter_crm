
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_state.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_pagination_bar.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_table.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_filter_sheet.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_states.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/employee_detail_screen_desktop.dart';


class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeListBloc>().add(const FetchEmployees());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToProfile(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<EmployeeListBloc>(),
          child: ModernEmployeeDetailScreen(employee: employee),
        ),
      ),
    );
  }

  void _emailSnack(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email: $email'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<String> _getDesignations(List<Employee> employees) {
    final seen = <String>{};
    return employees
        .map((e) => e.designation ?? '')
        .where((d) => d.isNotEmpty && seen.add(d))
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
          child: BlocBuilder<EmployeeListBloc, EmployeeListState>(
            builder: (context, state) {
              final employees = state.employeesWithStatus;
              final onlineCount =
                  state.liveStatusMap.values.where((e) => e).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminDashboardPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(state, employees, onlineCount),
                        Container(
                            height: 1, color: AdminDashboardTheme.borderSoft),
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AdminDashboardTheme.panelGap),
                  Expanded(
                    child: AdminDashboardPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildBody(state, employees)),
                          if (state.status != EmployeeListStatus.loading &&
                              employees.isNotEmpty)
                            EmployeePaginationBar(
                              currentPage: state.currentPage,
                              rowCount: employees.length,
                              totalCount: state.totalCount,
                              pageSize: EmployeeListBloc.pageSize,
                              onPageChanged: (page) => context
                                  .read<EmployeeListBloc>()
                                  .add(GoToPage(page)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      EmployeeListState state,
      List<Employee> employees,
      int onlineCount,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Directory",
                style: AdminDashboardTheme.companyTitle().copyWith(
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune_rounded,
                      color: AdminDashboardTheme.teal),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EmployeeFilterSheet(
                        designations: _getDesignations(employees),
                        selected: state.selectedRole,
                        onSelected: (val) => context
                            .read<EmployeeListBloc>()
                            .add(val == null
                            ? const ClearFilters()
                            : FilterByRole(val)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "${state.totalCount} employees",
                style: const TextStyle(
                  fontSize: 13,
                  color: AdminDashboardTheme.textMuted,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.active.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.active,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$onlineCount online",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.active,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            context.read<EmployeeListBloc>().add(SearchEmployees(value)),
        decoration: InputDecoration(
          hintText: 'Search by name, role, or ID...',
          hintStyle: const TextStyle(color: AdminDashboardTheme.textMuted),
          prefixIcon:
              const Icon(Icons.search, color: AdminDashboardTheme.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context
                  .read<EmployeeListBloc>()
                  .add(const SearchEmployees(''));
            },
          )
              : null,
          filled: true,
          fillColor: AdminDashboardTheme.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AdminDashboardTheme.teal),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBody(
      EmployeeListState state,
      List<Employee> employees,
      ) {
    if (state.status == EmployeeListStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AdminDashboardTheme.teal),
      );
    }

    if (state.status == EmployeeListStatus.failure &&
        employees.isEmpty) {
      return EmployeeErrorState(
        message: state.errorMessage,
        onRetry: () =>
            context.read<EmployeeListBloc>().add(const FetchEmployees()),
      );
    }

    if (employees.isEmpty &&
        state.status == EmployeeListStatus.success) {
      return EmployeeEmptyState(
        role: state.selectedRole,
        onClear: () =>
            context.read<EmployeeListBloc>().add(const ClearFilters()),
      );
    }

    return EmployeeTable(
      employees: employees,
      liveStatusMap: state.liveStatusMap,
      onViewProfile: _goToProfile,
      onEmail: (employee) => _emailSnack(employee.email),
    );
  }
}
