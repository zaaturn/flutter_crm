import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/employee_list.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/filter_bar.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/filter_enum.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/headers.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/stats_row.dart';

class MobileEmployeeSection extends StatefulWidget {
  final List<Employee> employees;
  final int totalEmployeeCount;
  final Function(Employee)? onEmployeeTap;
  /// When true, fits inside a scroll view with a fixed-height list (dashboard home).
  final bool embedded;

  const MobileEmployeeSection({
    super.key,
    required this.employees,
    required this.totalEmployeeCount,
    this.onEmployeeTap,
    this.embedded = false,
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

  bool _isCurrentlyWorking(Employee e) => e.liveStatus == LiveStatus.working;
  bool _isCurrentlyLoggedOut(Employee e) => e.liveStatus == LiveStatus.loggedOut;
  bool _isCurrentlyOnBreak(Employee e) => e.liveStatus == LiveStatus.breakTime;

  List<Employee> get _filtered {
    final q = _query.toLowerCase().trim();
    return widget.employees.where((e) {
      final statusMatch = switch (_filter) {
        EmployeeFilter.all => true,
        EmployeeFilter.working => _isCurrentlyWorking(e),
        EmployeeFilter.onBreak => _isCurrentlyOnBreak(e),
        EmployeeFilter.absent => _isCurrentlyLoggedOut(e),
      };
      if (!statusMatch) return false;
      if (q.isEmpty) return true;
      return e.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);

    final workingCount = widget.employees.where(_isCurrentlyWorking).length;
    final breakCount = widget.employees.where(_isCurrentlyOnBreak).length;
    final loggedOutCount = widget.employees.where(_isCurrentlyLoggedOut).length;
    final loggedInToday = widget.employees.length;
    final filtered = _filtered;

    final content = Column(
      children: [
        Container(
          color: lightCream,
          child: Header(
            totalEmployees: widget.totalEmployeeCount,
            loggedInToday: loggedInToday,
            searchOpen: _searchOpen,
            searchController: _search,
            searchWidth: _searchWidth,
            onSearchToggle: _toggleSearch,
          ),
        ),
        Container(
          color: lightCream,
          child: StatsRow(
            working: workingCount,
            onBreak: breakCount,
            absent: loggedOutCount,
          ),
        ),
        Container(
          color: lightCream,
          child: FilterBar(
            selected: _filter,
            counts: {
              EmployeeFilter.all: loggedInToday,
              EmployeeFilter.working: workingCount,
              EmployeeFilter.onBreak: breakCount,
              EmployeeFilter.absent: loggedOutCount,
            },
            onSelect: (f) => setState(() => _filter = f),
          ),
        ),
        if (widget.embedded)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: _buildEmployeeList(filtered, lightCream),
          )
        else
          Expanded(child: _buildEmployeeList(filtered, lightCream)),
      ],
    );

    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: lightCream,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.12)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: content,
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<Employee> filtered, Color lightCream) {
    if (filtered.isEmpty) {
      return Container(
        color: lightCream,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Text(
          widget.employees.isEmpty
              ? 'No employees logged in today'
              : 'No employees match this filter',
          style: GoogleFonts.manrope(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      color: lightCream,
      child: EmployeeList(
        employees: filtered,
        scrollController: _scroll,
        onTap: widget.onEmployeeTap,
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
