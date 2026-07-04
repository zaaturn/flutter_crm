import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_detail_shared.dart'
    show formatJoinDate;
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

/// Column width proportions shared between the header and every data row
/// so cells line up regardless of window width.
class _Cols {
  static const code = 1;
  static const employee = 3;
  static const designation = 2;
  static const department = 2;
  static const joined = 2;
  static const status = 2;
  static const actions = 1;
}

class EmployeeTable extends StatelessWidget {
  final List<Employee> employees;
  final Map<int, bool> liveStatusMap;
  final ValueChanged<Employee> onViewProfile;
  final ValueChanged<Employee> onEmail;

  const EmployeeTable({
    super.key,
    required this.employees,
    required this.liveStatusMap,
    required this.onViewProfile,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EmployeeTableHeader(),
        Container(height: 1, color: AdminDashboardTheme.borderSoft),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: employees.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              color: AdminDashboardTheme.borderSoft,
            ),
            itemBuilder: (context, index) {
              final employee = employees[index];
              final isOnline = liveStatusMap[employee.id] ?? false;
              return _EmployeeTableRow(
                employee: employee,
                isOnline: isOnline,
                onViewProfile: () => onViewProfile(employee),
                onEmail: () => onEmail(employee),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmployeeTableHeader extends StatelessWidget {
  const _EmployeeTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AdminDashboardTheme.surfaceMuted,
      ),
      child: Row(
        children: const [
          Expanded(flex: _Cols.code, child: _HeaderLabel('Code')),
          Expanded(flex: _Cols.employee, child: _HeaderLabel('Employee')),
          Expanded(
              flex: _Cols.designation, child: _HeaderLabel('Designation')),
          Expanded(flex: _Cols.department, child: _HeaderLabel('Department')),
          Expanded(flex: _Cols.joined, child: _HeaderLabel('Joined')),
          Expanded(flex: _Cols.status, child: _HeaderLabel('Status')),
          Expanded(
              flex: _Cols.actions,
              child: _HeaderLabel('Actions', alignEnd: true)),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  final bool alignEnd;

  const _HeaderLabel(this.label, {this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AdminDashboardTheme.textMuted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmployeeTableRow extends StatefulWidget {
  final Employee employee;
  final bool isOnline;
  final VoidCallback onViewProfile;
  final VoidCallback onEmail;

  const _EmployeeTableRow({
    required this.employee,
    required this.isOnline,
    required this.onViewProfile,
    required this.onEmail,
  });

  @override
  State<_EmployeeTableRow> createState() => _EmployeeTableRowState();
}

class _EmployeeTableRowState extends State<_EmployeeTableRow> {
  bool _hovering = false;

  static const _cellTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AdminDashboardTheme.textDark,
    height: 1.3,
  );

  Color get _avatarColor {
    const colors = [
      AppColors.primary,
      Color(0xFF0EA5E9),
      AppColors.active,
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[(widget.employee.employeeId.hashCode.abs()) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onViewProfile,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _hovering
              ? AdminDashboardTheme.surfaceMuted
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: _Cols.code,
                child: Text(
                  employee.employeeId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AdminDashboardTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: _Cols.employee,
                child: Row(
                  children: [
                    _Avatar(employee: employee, isOnline: widget.isOnline, color: _avatarColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            employee.fullName,
                            style: AppTextStyles.title.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            employee.email,
                            style: AppTextStyles.small,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: _Cols.designation,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    employee.designation?.isNotEmpty == true
                        ? employee.designation!
                        : '—',
                    style: _cellTextStyle,
                    softWrap: true,
                  ),
                ),
              ),
              Expanded(
                flex: _Cols.department,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    employee.department?.isNotEmpty == true
                        ? employee.department!
                        : '—',
                    style: _cellTextStyle,
                    softWrap: true,
                  ),
                ),
              ),
              Expanded(
                flex: _Cols.joined,
                child: Text(
                  formatJoinDate(employee.dateOfJoining),
                  style: _cellTextStyle,
                  softWrap: true,
                ),
              ),
              Expanded(
                flex: _Cols.status,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(isOnline: widget.isOnline),
                ),
              ),
              Expanded(
                flex: _Cols.actions,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _ActionsMenu(
                    onViewProfile: widget.onViewProfile,
                    onEmail: widget.onEmail,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Employee employee;
  final bool isOnline;
  final Color color;

  const _Avatar({required this.employee, required this.isOnline, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withOpacity(0.12),
            backgroundImage: employee.profilePhoto?.isNotEmpty == true
                ? NetworkImage(employee.profilePhoto!)
                : null,
            onBackgroundImageError:
                employee.profilePhoto?.isNotEmpty == true ? (_, __) {} : null,
            child: employee.profilePhoto?.isNotEmpty == true
                ? null
                : Text(
                    employee.initials,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
          ),
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.active : AppColors.offline,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOnline;

  const _StatusBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.active : AppColors.textSubtle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOnline ? 'ONLINE' : 'OFFLINE',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  final VoidCallback onViewProfile;
  final VoidCallback onEmail;

  const _ActionsMenu({required this.onViewProfile, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AdminDashboardTheme.border),
      ),
      color: Colors.white,
      onSelected: (value) {
        if (value == 'view') onViewProfile();
        if (value == 'email') onEmail();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'view',
          child: _MenuRow(icon: Icons.person_outline, label: 'View profile'),
        ),
        PopupMenuItem(
          value: 'email',
          child: _MenuRow(icon: Icons.mail_outline, label: 'Send email'),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AdminDashboardTheme.teal,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AdminDashboardTheme.teal),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminDashboardTheme.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminDashboardTheme.textDark,
          ),
        ),
      ],
    );
  }
}
