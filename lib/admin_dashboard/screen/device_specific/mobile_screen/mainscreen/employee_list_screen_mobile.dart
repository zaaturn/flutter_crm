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
import 'employee_detail_mobile_screen.dart';
import '../widgets/saas_employee_tile.dart';

class EmployeeListScreenMobile extends StatefulWidget {
  final VoidCallback? onBack;

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
          child: EmployeeDetailMobileScreen(employee: employee),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);
    const Color darkSlate = Color(0xFF0F172A);
    const Color terracotta = Color(0xFFB35A38);
    const Color fieldFill = Color(0xFFEADBC8);
    const Color textMuted = Color(0xFF8D6E63);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: lightCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkSlate, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onBack?.call();
            }
          },
        ),
        title: Text(
          "Staff",
          style: GoogleFonts.manrope(
            color: darkSlate,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<EmployeeListBloc, EmployeeListState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: darkSlate,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    hintStyle: GoogleFonts.manrope(
                      color: textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: terracotta,
                    ),
                    filled: true,
                    fillColor: fieldFill,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: terracotta.withValues(alpha: 0.28),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: terracotta, width: 2.0),
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
      color: const Color(0xFFB35A38),
      backgroundColor: Colors.white,
      onRefresh: () async {
        context.read<EmployeeListBloc>().add(const FetchEmployees());
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6, bottom: 18),
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