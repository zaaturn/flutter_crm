
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_state.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/utils/app_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_card.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_card_shimmer.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_filter_sheet.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_states.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/employee_detail_screen_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_card_shimmer.dart';


class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<EmployeeListBloc>().add(const FetchEmployees());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        context.read<EmployeeListBloc>().add(const LoadMoreEmployees());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  int _getCrossAxisCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 1100) return 3;
    if (width >= 800) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: BlocBuilder<EmployeeListBloc, EmployeeListState>(
          builder: (context, state) {
            final employees = state.employeesWithStatus;
            final onlineCount =
                state.liveStatusMap.values.where((e) => e).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(state, employees, onlineCount),
                _buildSearchBar(),
                const Divider(height: 1),
                Expanded(child: _buildBody(state, employees)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      EmployeeListState state,
      List<Employee> employees,
      int onlineCount,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Directory",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
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
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                "${state.totalCount} employees",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$onlineCount online",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            context.read<EmployeeListBloc>().add(SearchEmployees(value)),
        decoration: InputDecoration(
          hintText: 'Search by name, role, or ID...',
          prefixIcon: const Icon(Icons.search),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      EmployeeListState state,
      List<Employee> employees,
      ) {
    if (state.status == EmployeeListStatus.loading) {
      return const EmployeeShimmerList();
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

    final crossAxisCount =
    _getCrossAxisCount(MediaQuery.of(context).size.width);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: employees.length +
          (state.status == EmployeeListStatus.loadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= employees.length) {
          return const EmployeeShimmerCard();
        }

        final employee = employees[index];

        return EmployeeCard(
          employee: employee,
          onViewProfile: () => _goToProfile(employee),
          onEmail: () => _emailSnack(employee.email),
        );
      },
    );
  }
}
