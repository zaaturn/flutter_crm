import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

import 'apply_leave_form.dart';

/// Loads leave detail and leave types in parallel, then shows [ApplyLeaveForm].
///
/// Shows the dialog/sheet immediately; only this body blocks on network.
class PendingEditLeaveLoader extends StatefulWidget {
  final LeaveRequest initialLeave;
  final List<LeaveType> seedLeaveTypes;
  final LeaveBloc leaveBloc;
  final bool useRootNavigatorForPop;

  const PendingEditLeaveLoader({
    super.key,
    required this.initialLeave,
    required this.seedLeaveTypes,
    required this.leaveBloc,
    this.useRootNavigatorForPop = true,
  });

  @override
  State<PendingEditLeaveLoader> createState() => _PendingEditLeaveLoaderState();
}

class _PendingEditLeaveLoaderState extends State<PendingEditLeaveLoader> {
  LeaveRequest? _leave;
  List<LeaveType>? _types;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.initialLeave.id;
    if (id == null) {
      setState(() => _error = 'Missing leave id');
      return;
    }
    final api = LeaveApiService();
    try {
      final typesFuture = widget.seedLeaveTypes.isNotEmpty
          ? Future<List<LeaveType>>.value(
              List<LeaveType>.from(widget.seedLeaveTypes),
            )
          : api.getLeaveTypes();
      final results = await Future.wait<dynamic>([
        api.getMyLeaveDetail(id),
        typesFuture,
      ]);
      if (!mounted) return;
      setState(() {
        _leave = results[0] as LeaveRequest;
        _types = results[1] as List<LeaveType>;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _leave = null;
        _types = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, height: 1.4),
        ),
      );
    }
    final leave = _leave;
    final types = _types;
    if (leave == null || types == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40),
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF2563EB),
          ),
          SizedBox(height: 16),
          Text(
            'Loading…',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          SizedBox(height: 40),
        ],
      );
    }
    return BlocProvider.value(
      value: widget.leaveBloc,
      child: ApplyLeaveForm(
        leaveTypes: types,
        existingLeave: leave,
        useRootNavigatorForPop: widget.useRootNavigatorForPop,
      ),
    );
  }
}
