import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_state.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_card_shimmer.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_states.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/employee_detail_screen_desktop.dart';
import '../widgets/saas_employee_tile.dart';

class EmployeeListScreenMobile extends StatefulWidget {
  final VoidCallback? onBack; // Add this callback

  const EmployeeListScreenMobile({super.key, this.onBack});

  @override
  State<EmployeeListScreenMobile> createState() => _EmployeeListScreenMobileState();
}

class _EmployeeListScreenMobileState extends State<EmployeeListScreenMobile> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeListBloc>().add(const FetchEmployees());

    _scrollController.addListener(() {
      if (_scrollController.hasClients && 
          _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
        final state = context.read<EmployeeListBloc>().state;
        if (state.status != EmployeeListStatus.loadingMore && state.hasMore) {
          context.read<EmployeeListBloc>().add(const LoadMoreEmployees());
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<EmployeeListBloc>().add(SearchEmployees(query));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            // 💡 If we can't pop (meaning it's a tab), trigger the onBack callback
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onBack?.call();
            }
          },
        ),
        title: Text(
          "Current Staff",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<EmployeeListBloc, EmployeeListState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildListBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListBody(EmployeeListState state) {
    if (state.status == EmployeeListStatus.loading && state.employees.isEmpty) {
      return const EmployeeShimmerList();
    }

    if (state.employees.isEmpty && state.status == EmployeeListStatus.success) {
      return Center(
        child: EmployeeEmptyState(
          role: state.selectedRole,
          onClear: () => context.read<EmployeeListBloc>().add(const ClearFilters()),
        ),
      );
    }

    final employees = state.employees;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<EmployeeListBloc>().add(const FetchEmployees());
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: employees.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= employees.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          final employee = employees[index];
          return SaasEmployeeTile(
            employee: employee,
            onTap: () => _goToProfile(employee),
          );
        },
      ),
    );
  }
}
