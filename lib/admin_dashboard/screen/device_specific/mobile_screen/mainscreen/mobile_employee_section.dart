import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/employee_list.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/filter_bar.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/filter_enum.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/headers.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/stats_row.dart';

class MobileEmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final Function(Employee)? onEmployeeTap;

  const MobileEmployeeSection({
    super.key,
    required this.employees,
    this.onEmployeeTap,
  });

  @override
  State<MobileEmployeeSection> createState() => _MobileEmployeeSectionState();
}

class _MobileEmployeeSectionState extends State<MobileEmployeeSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  EmployeeFilter _filter = EmployeeFilter.all;
  String _query = '';
  bool _searchOpen = false;

  late AnimationController _searchAnim;
  late Animation<double> _searchWidth;

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _searchWidth = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOutCubic,
    );
    _search.addListener(() => setState(() => _query = _search.text));
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    _searchAnim.dispose();
    super.dispose();
  }


  bool _isCurrentlyWorking(Employee e) {
    return e.liveStatus == LiveStatus.working;
  }

  bool _isCurrentlyAbsent(Employee e) {
    return e.liveStatus == LiveStatus.loggedOut;
  }

  bool _isCurrentlyOnBreak(Employee e) {
    return e.liveStatus == LiveStatus.breakTime;
  }

  List<Employee> get _filtered {
    final q = _query.toLowerCase().trim();

    return widget.employees.where((e) {

      final statusMatch = switch (_filter) {
        EmployeeFilter.all => true,
        EmployeeFilter.working => _isCurrentlyWorking(e),
        EmployeeFilter.onBreak => _isCurrentlyOnBreak(e),
        EmployeeFilter.absent => _isCurrentlyAbsent(e),
      };

      if (!statusMatch) return false;
      if (q.isEmpty) return true;

      // Search
      final name = (e.name.isNotEmpty ? e.name : e.fullName).toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final workingCount =
        widget.employees.where(_isCurrentlyWorking).length;

    final breakCount =
        widget.employees.where(_isCurrentlyOnBreak).length;

    final absentCount =
        widget.employees.where(_isCurrentlyAbsent).length;

    final filtered = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Header(
            total: widget.employees.length,
            workingCount: workingCount,
            searchOpen: _searchOpen,
            searchController: _search,
            searchWidth: _searchWidth,
            onSearchToggle: _toggleSearch,
          ),
          StatsRow(
            working: workingCount,
            onBreak: breakCount,
            absent: absentCount,
          ),
          FilterBar(
            selected: _filter,
            counts: {
              EmployeeFilter.all: widget.employees.length,
              EmployeeFilter.working: workingCount,
              EmployeeFilter.onBreak: breakCount,
              EmployeeFilter.absent: absentCount,
            },
            onSelect: (f) => setState(() => _filter = f),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: EmployeeList(
              employees: filtered,
              scrollController: _scroll,
              onTap: widget.onEmployeeTap,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchAnim.forward();
    } else {
      _searchAnim.reverse();
      _search.clear();
    }
  }
}