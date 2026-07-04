import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/mobile_feature_grid.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/admin_top_bar_mobile.dart';

/// Mobile admin home — module grid only (no live attendance, no embedded analytics).
class MobileDashboardHomeTab extends StatelessWidget {
  const MobileDashboardHomeTab({super.key, required this.state});

  final AdminDashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC05E41)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminTopBarMobile(),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFC05E41),
            onRefresh: () async {
              context
                  .read<AdminDashboardBloc>()
                  .add(const AdminDashboardRefreshed());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
              child: MobileFeatureGrid(
                employees: state.liveEmployees,
                totalEmployeeCount: state.totalEmployeeCount,
                isSuperuser: state.isSuperuser,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
