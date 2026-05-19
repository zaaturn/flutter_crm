import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_detail_shared.dart';

import 'employee_detail_mobile_theme.dart';

class EmployeeDetailMobileBody extends StatelessWidget {
  const EmployeeDetailMobileBody({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(employee: employee),
          const SizedBox(height: 12),
          _QuickStats(employee: employee),
          const SizedBox(height: 12),
          _MobileSectionCard(
            title: 'Personal',
            icon: Icons.person_outline_rounded,
            children: [
              _MobileInfoRow(
                label: 'Full name',
                value: employee.fullName,
              ),
              _MobileInfoRow(
                label: 'First name',
                value: employee.firstName,
              ),
              _MobileInfoRow(
                label: 'Last name',
                value: employee.lastName,
              ),
              if (employee.dateOfBirth != null &&
                  employee.dateOfBirth!.isNotEmpty)
                _MobileInfoRow(
                  label: 'Date of birth',
                  value: formatDate(employee.dateOfBirth),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _MobileSectionCard(
            title: 'Employment',
            icon: Icons.work_outline_rounded,
            children: [
              _MobileInfoRow(
                label: 'Employee ID',
                value: employee.employeeId,
                copyable: true,
              ),
              _MobileInfoRow(
                label: 'Designation',
                value: employee.designation ?? '—',
              ),
              _MobileInfoRow(
                label: 'Department',
                value: employee.department ?? '—',
              ),
              _MobileInfoRow(
                label: 'Date of joining',
                value: formatDate(employee.dateOfJoining),
              ),
              _MobileInfoRow(
                label: 'Status',
                value: employee.isActive ? 'Active' : 'Inactive',
                valueWidget: _StatusChip(isActive: employee.isActive),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MobileSectionCard(
            title: 'Contact',
            icon: Icons.contact_mail_outlined,
            children: [
              _MobileInfoRow(
                label: 'Email',
                value: employee.email,
                copyable: true,
              ),
              _MobileInfoRow(
                label: 'Phone',
                value: employee.phoneNumber ?? '—',
                copyable: employee.phoneNumber != null &&
                    employee.phoneNumber!.trim().isNotEmpty,
              ),
              _MobileInfoRow(
                label: 'Username',
                value: employee.profileUsernameHandle,
              ),
              if (employee.address != null && employee.address!.isNotEmpty)
                _MobileInfoRow(
                  label: 'Address',
                  value: employee.address!,
                  maxLines: 4,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _MobileSectionCard(
            title: 'Work location',
            icon: Icons.location_on_outlined,
            children: [
              _MobileInfoRow(
                label: 'Office',
                value: employee.workLocation ?? '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        employee.profilePhoto != null && employee.profilePhoto!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: EmployeeDetailMobileTheme.cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: EmployeeDetailMobileTheme.primarySoftSurface,
            backgroundImage:
                hasPhoto ? NetworkImage(employee.profilePhoto!) : null,
            child: !hasPhoto
                ? Text(
                    employee.initials,
                    style: EmployeeDetailMobileTheme.sectionTitle().copyWith(
                      fontSize: 22,
                      color: EmployeeDetailMobileTheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            employee.fullName,
            textAlign: TextAlign.center,
            style: EmployeeDetailMobileTheme.sectionTitle().copyWith(
              fontSize: 18,
            ),
          ),
          if (employee.designation != null &&
              employee.designation!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: EmployeeDetailMobileTheme.primarySoftSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: EmployeeDetailMobileTheme.primary.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Text(
                employee.designation!.trim(),
                style: EmployeeDetailMobileTheme.label().copyWith(
                  color: EmployeeDetailMobileTheme.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final rawId = employee.employeeId.toString();
    final sanitizedId = rawId.replaceAll(' ', '');

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Tenure',
            value: formatJoinDate(employee.dateOfJoining),
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Employee ID',
            value: sanitizedId.isEmpty ? '—' : sanitizedId,
            icon: Icons.badge_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: EmployeeDetailMobileTheme.cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EmployeeDetailMobileTheme.primarySoftSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: EmployeeDetailMobileTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: EmployeeDetailMobileTheme.label()),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: EmployeeDetailMobileTheme.value().copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSectionCard extends StatelessWidget {
  const _MobileSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: EmployeeDetailMobileTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EmployeeDetailMobileTheme.primarySoftSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: EmployeeDetailMobileTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(title, style: EmployeeDetailMobileTheme.sectionTitle()),
              ],
            ),
          ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: EmployeeDetailMobileTheme.border.withValues(alpha: 0.7),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: children[i],
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  const _MobileInfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.valueWidget,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final bool copyable;
  final Widget? valueWidget;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: EmployeeDetailMobileTheme.label()),
              const SizedBox(height: 4),
              valueWidget ??
                  Text(
                    value,
                    style: EmployeeDetailMobileTheme.value(),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
            ],
          ),
        ),
        if (copyable && value.trim().isNotEmpty)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: EmployeeDetailMobileTheme.primary,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFF0F766E)
        : const Color(0xFFB91C1C);
    final bg = isActive
        ? const Color(0xFFCCFBF1)
        : const Color(0xFFFFE4E6);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: EmployeeDetailMobileTheme.value().copyWith(
            fontSize: 13,
            color: color,
          ),
        ),
      ),
    );
  }
}
