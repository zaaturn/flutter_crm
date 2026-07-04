import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_widgets_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/welcome_header_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_section_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/admin_dashboard_overview_section.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/admin_client_summary_panel.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/repository/client_dashboard_summary_repository.dart';
import 'package:my_app/core/keyboard/keyboard_navigation.dart';

class AdminDashboardDesktop extends StatelessWidget {
  const AdminDashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AdminDashboardTheme.shellPadding),
          child: _AdminDashboardDesktopView(),
        ),
      ),
    );
  }
}

class _AdminDashboardDesktopView extends StatefulWidget {
  const _AdminDashboardDesktopView();

  @override
  State<_AdminDashboardDesktopView> createState() =>
      _AdminDashboardDesktopViewState();
}

class _AdminDashboardDesktopViewState
    extends State<_AdminDashboardDesktopView> {
  Timer? _liveStatusTimer;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _sidebarFocusNode = FocusNode(debugLabel: 'AdminSidebarFocus');
  final FocusNode _contentFocusNode = FocusNode(debugLabel: 'AdminContentFocus');
  late final ClientDashboardSummaryCubit _clientSummaryCubit;

  static const _gap = AdminDashboardTheme.panelGap;
  static const _splitPanelHeight = 380.0;

  bool _initialLoad(AdminDashboardState state) =>
      state.isLoading && state.username == null;

  void _syncScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final max = position.maxScrollExtent;
      final pixels = position.pixels;
      if (pixels > max) {
        _scrollController.jumpTo(max);
      } else if (pixels < 0) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _clientSummaryCubit = ClientDashboardSummaryCubit(
      ClientDashboardSummaryRepository(),
    )..initialize();
    context.read<AdminDashboardBloc>().add(AdminDashboardStarted());
    _liveStatusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      context.read<AdminDashboardBloc>().add(const AdminDashboardRefreshed());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sidebarFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _liveStatusTimer?.cancel();
    _clientSummaryCubit.close();
    _scrollController.dispose();
    _sidebarFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
      listenWhen: (previous, current) =>
          (previous.isLoading && !current.isLoading) ||
          previous.liveEmployees.length != current.liveEmployees.length ||
          previous.totalEmployeeCount != current.totalEmployeeCount,
      listener: (context, state) {
        _syncScrollPosition();
      },
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminDashboardPanel(
              margin: const EdgeInsets.only(right: _gap),
              width: AdminDashboardTheme.railWidth,
              child: DashboardSidebarFocusScope(
                focusNode: _sidebarFocusNode,
                onMoveToContent: () => _contentFocusNode.requestFocus(),
                child: DesktopSidebar(
                  parentContext: context,
                  userName: state.username ?? 'Admin',
                  userRole: state.role ?? 'Super Admin',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ModernDashboardHeader(
                      adminName: state.username ?? 'Admin',
                      parentContext: context,
                      showWorkspaceSwitcher:
                          state.role?.toLowerCase() == 'admin',
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          KeyboardScrollRegion(
                            scrollController: _scrollController,
                            focusNode: _contentFocusNode,
                            onMoveToPreviousRegion: () =>
                                _sidebarFocusNode.requestFocus(),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              primary: false,
                              physics: const ClampingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AdminDashboardOverviewSection(state: state),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    height: _splitPanelHeight,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: AdminDashboardPanel(
                                            child: DesktopEmployeeSection(
                                              employees: state.liveEmployees,
                                              totalEmployeeCount:
                                                  state.totalEmployeeCount,
                                              flat: true,
                                              compact: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: _gap),
                                        Expanded(
                                          child: AdminDashboardPanel(
                                            child: BlocProvider.value(
                                              value: _clientSummaryCubit,
                                              child:
                                                  const AdminClientSummaryPanel(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: _gap),
                                ],
                              ),
                            ),
                          ),
                          if (_initialLoad(state))
                            Positioned.fill(
                              child: ColoredBox(
                                color: AdminDashboardTheme.shellMint
                                    .withValues(alpha: 0.92),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AdminDashboardTheme.teal,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
