import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'employee_tile.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;
  final ScrollController scrollController;
  final Function(Employee)? onTap;

  const EmployeeList({
    super.key,
    required this.employees,
    required this.scrollController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: ValueKey(employees.length),
      controller: scrollController,
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: employees.length,
      itemBuilder: (context, i) {
        final employee = employees[i];

        return EmployeeTile(
          key: ValueKey(employee.id),
          employee: employee,
          onTap: () => onTap?.call(employee),
        );
      },
    );
  }
}