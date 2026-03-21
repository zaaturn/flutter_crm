import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class Avatar extends StatelessWidget {
  final Employee employee;

  const Avatar({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(employee.initials),
    );
  }
}