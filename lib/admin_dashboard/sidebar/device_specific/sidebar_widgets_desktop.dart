import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_menu_config_desktop.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_handler_desktop.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/core/widgets/app_material_icon.dart';
import 'package:my_app/core/widgets/sidebar_chart_icon.dart';
import 'package:my_app/core/keyboard/keyboard_navigation.dart';

/// Narrow icon rail — matches reference mockup (logo, pill nav, yellow active).
class DesktopSidebar extends StatefulWidget {
  final BuildContext parentContext;
  final String userName;
  final String userRole;
  final String? userAvatar;
  final VoidCallback? onLogout;

  const DesktopSidebar({
    super.key,
    required this.parentContext,
    required this.userName,
    required this.userRole,
    this.userAvatar,
    this.onLogout,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  SidebarAction? _selectedAction = SidebarAction.analytics;

  Map<String, bool> _adminModules = {};
  bool _isSuperuser = false;
  bool _roleIsAdmin = false;

  @override
  void initState() {
    super.initState();
    ProfileRemoteSync.authSessionEpoch.addListener(_onAuthSessionEpoch);
    _loadSession();
  }

  @override
  void dispose() {
    ProfileRemoteSync.authSessionEpoch.removeListener(_onAuthSessionEpoch);
    super.dispose();
  }

  void _onAuthSessionEpoch() => _loadSession();

  Future<void> _loadSession() async {
    final storage = SecureStorageService();
    final raw = await storage.readAuthSessionJson();
    final session = AuthSession.fromStorageString(raw);
    final role = await storage.readRole();
    if (!mounted) return;
    setState(() {
      _adminModules = session?.adminModules ?? {};
      _isSuperuser = session?.isSuperuser ?? false;
      _roleIsAdmin = role?.toLowerCase() == 'admin';
    });
  }

  bool _moduleAllowed(String? moduleKey) {
    if (_isSuperuser) return true;
    if (moduleKey == null || moduleKey.isEmpty) return true;
    if (moduleKey == 'payroll') {
      return _isSuperuser ||
          (_roleIsAdmin && _adminModules['payroll'] == true);
    }
    if (moduleKey == 'analytics') {
      return _adminModules['analytics'] == true;
    }
    return _adminModules[moduleKey] ?? true;
  }

  List<SidebarAction> _visibleActions() {
    final actions = <SidebarAction>[];
    if (_isSuperuser) actions.add(SidebarAction.superadminUsers);
    for (final item in sidebarMenuConfig) {
      if (item.children != null && item.children!.isNotEmpty) {
        for (final child in item.children!) {
          if (_moduleAllowed(child.moduleKey) && child.action != null) {
            actions.add(child.action!);
          }
        }
      } else if (_moduleAllowed(item.moduleKey) && item.action != null) {
        actions.add(item.action!);
      }
    }
    return actions;
  }

  int _selectedKeyboardIndex(List<SidebarAction> actions) {
    if (_selectedAction == null || actions.isEmpty) return 0;
    final idx = actions.indexOf(_selectedAction!);
    return idx >= 0 ? idx : 0;
  }

  void _onKeyboardIndexChanged(int index) {
    final actions = _visibleActions();
    if (index < 0 || index >= actions.length) return;
    setState(() => _selectedAction = actions[index]);
  }

  void _onKeyboardActivate() {
    final actions = _visibleActions();
    final index = _selectedKeyboardIndex(actions);
    if (index < actions.length) _onAction(actions[index]);
  }

  bool _isGroupSelected(SidebarMenuItem item) {
    final children = item.children;
    if (children == null) return false;
    return children.any((c) => c.action == _selectedAction);
  }

  bool _isItemSelected(SidebarMenuItem item) =>
      item.action != null && item.action == _selectedAction;

  void _onAction(SidebarAction? action) {
    if (action == null) return;
    if (action != SidebarAction.logout) {
      setState(() => _selectedAction = action);
    }
    SidebarHandler.handle(context, widget.parentContext, action);
  }

  void _openGroupMenu(
    BuildContext anchorContext,
    SidebarMenuItem item,
    List<SidebarMenuItem> children,
  ) {
    final box = anchorContext.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final hasSelectedChild = _isGroupSelected(item);

    showMenu<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AdminDashboardTheme.surface,
      position: RelativeRect.fromLTRB(
        offset.dx + box.size.width + 8,
        offset.dy,
        offset.dx + box.size.width + 240,
        offset.dy + 280,
      ),
      items: children.map((child) {
        final selected = child.action == _selectedAction;
        return PopupMenuItem<void>(
          onTap: () {
            if (child.action != null) {
              Future.microtask(() => _onAction(child.action));
            }
          },
          child: Row(
            children: [
              AppMaterialIcon(
                child.icon,
                size: 18,
                color: selected
                    ? AdminDashboardTheme.teal
                    : AdminDashboardTheme.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  child.title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AdminDashboardTheme.tealDark
                        : AdminDashboardTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (!hasSelectedChild && children.isNotEmpty) {
      setState(() {});
    }
  }

  List<Widget> _buildNavIcons() {
    final widgets = <Widget>[];

    if (_isSuperuser) {
      widgets.add(_railIcon(
        icon: Icons.manage_accounts_outlined,
        tooltip: 'Manage users',
        selected: _selectedAction == SidebarAction.superadminUsers,
        onTap: () => _onAction(SidebarAction.superadminUsers),
      ));
    }

    for (final item in sidebarMenuConfig) {
      if (!_moduleAllowed(item.moduleKey)) continue;

      if (item.children != null && item.children!.isNotEmpty) {
        final visibleChildren =
            item.children!.where((c) => _moduleAllowed(c.moduleKey)).toList();
        if (visibleChildren.isEmpty) continue;

        widgets.add(_RailIconAnchor(
          builder: (anchorCtx) => _railIcon(
            icon: item.icon,
            tooltip: item.title,
            selected: _isGroupSelected(item),
            onTap: () => _openGroupMenu(anchorCtx, item, visibleChildren),
          ),
        ));
        continue;
      }

      if (item.action == null) continue;

      final selected = _isItemSelected(item);
      widgets.add(_railIcon(
        icon: item.icon,
        tooltip: item.tooltip ?? item.title,
        selected: selected,
        onTap: () => _onAction(item.action),
        customIcon: item.action == SidebarAction.analytics
            ? SidebarChartIcon(
                size: 22,
                color: selected
                    ? AdminDashboardTheme.textDark
                    : AdminDashboardTheme.iconInactive,
              )
            : null,
      ));
    }

    return widgets;
  }

  Widget _railIcon({
    required IconData icon,
    required String tooltip,
    required bool selected,
    required VoidCallback onTap,
    Widget? customIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AdminDashboardTheme.accentYellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: customIcon ??
                  AppMaterialIcon(
                    icon,
                    size: 22,
                    color: selected
                        ? AdminDashboardTheme.textDark
                        : AdminDashboardTheme.iconInactive,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = _visibleActions();
    final keyboardScope = dashboardSidebarKeyboardScopeOf(context);
    final navIcons = _buildNavIcons();

    return SizedBox(
      width: AdminDashboardTheme.railWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 20),
        child: Column(
          children: [
            _buildSidebarLogo(),
            const SizedBox(height: 10),
            Expanded(
              child: KeyboardNavList(
                itemCount: actions.length,
                selectedIndex: _selectedKeyboardIndex(actions),
                onSelectedIndexChanged: _onKeyboardIndexChanged,
                onActivate: _onKeyboardActivate,
                autofocus: true,
                focusNode: keyboardScope?.focusNode,
                onMoveToNextRegion: keyboardScope?.onMoveToContent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AdminDashboardTheme.iconRailBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    physics: const BouncingScrollPhysics(),
                    children: navIcons,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AdminDashboardTheme.iconRailBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _railIcon(
                    icon: Icons.settings_outlined,
                    tooltip: 'Settings',
                    selected: false,
                    onTap: () {},
                    customIcon: SidebarSettingsIcon(
                      size: 22,
                      color: AdminDashboardTheme.iconInactive,
                    ),
                  ),
                  _railIcon(
                    icon: Icons.headset_mic_outlined,
                    tooltip: 'Support',
                    selected: false,
                    onTap: () {},
                    customIcon: SidebarSupportIcon(
                      size: 22,
                      color: AdminDashboardTheme.iconInactive,
                    ),
                  ),
                  _railIcon(
                    icon: Icons.logout_rounded,
                    tooltip: 'Logout',
                    selected: false,
                    onTap: () => _onAction(SidebarAction.logout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarLogo() {
    return Column(
      children: [
        ClipOval(
          child: SizedBox(
            width: 44,
            height: 44,
            child: ColoredBox(
              color: AdminDashboardTheme.tealLight,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const AppMaterialIcon(
                  Icons.auto_awesome_rounded,
                  color: AdminDashboardTheme.teal,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'DAXARROW',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: AdminDashboardTheme.tealDark,
          ),
        ),
      ],
    );
  }
}

/// Provides [BuildContext] at the icon for positioning flyout menus.
class _RailIconAnchor extends StatelessWidget {
  final Widget Function(BuildContext anchorContext) builder;

  const _RailIconAnchor({required this.builder});

  @override
  Widget build(BuildContext context) => Builder(builder: builder);
}
