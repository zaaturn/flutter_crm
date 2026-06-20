import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Arrow up/down + Enter/Space for a flat list (sidebar items, tabs, etc.).
class KeyboardNavList extends StatefulWidget {
  const KeyboardNavList({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.onActivate,
    required this.child,
    this.autofocus = true,
    this.focusNode,
    this.onMoveToNextRegion,
  });

  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final VoidCallback onActivate;
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onMoveToNextRegion;

  @override
  State<KeyboardNavList> createState() => _KeyboardNavListState();
}

class _KeyboardNavListState extends State<KeyboardNavList> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode(debugLabel: 'KeyboardNavList');
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.itemCount <= 0) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      final next = (widget.selectedIndex + 1).clamp(0, widget.itemCount - 1);
      if (next != widget.selectedIndex) widget.onSelectedIndexChanged(next);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      final next = (widget.selectedIndex - 1).clamp(0, widget.itemCount - 1);
      if (next != widget.selectedIndex) widget.onSelectedIndexChanged(next);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.home) {
      if (widget.selectedIndex != 0) widget.onSelectedIndexChanged(0);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.end) {
      final last = widget.itemCount - 1;
      if (widget.selectedIndex != last) widget.onSelectedIndexChanged(last);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      widget.onActivate();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowRight && widget.onMoveToNextRegion != null) {
      widget.onMoveToNextRegion!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}

/// Arrow keys scroll a [ScrollController]; Left returns to sidebar when provided.
class KeyboardScrollRegion extends StatefulWidget {
  const KeyboardScrollRegion({
    super.key,
    required this.scrollController,
    required this.child,
    this.scrollStep = 88,
    this.pageStep = 420,
    this.focusNode,
    this.onMoveToPreviousRegion,
  });

  final ScrollController scrollController;
  final Widget child;
  final double scrollStep;
  final double pageStep;
  final FocusNode? focusNode;
  final VoidCallback? onMoveToPreviousRegion;

  @override
  State<KeyboardScrollRegion> createState() => _KeyboardScrollRegionState();
}

class _KeyboardScrollRegionState extends State<KeyboardScrollRegion> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode(debugLabel: 'KeyboardScrollRegion');
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final controller = widget.scrollController;
    if (!controller.hasClients) return;
    final target = (controller.offset + delta)
        .clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _scrollBy(widget.scrollStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _scrollBy(-widget.scrollStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _scrollBy(widget.pageStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _scrollBy(-widget.pageStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft && widget.onMoveToPreviousRegion != null) {
      widget.onMoveToPreviousRegion!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _focusNode.requestFocus(),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: widget.child,
      ),
    );
  }
}

/// Wrap dashboards so sidebars receive shared focus coordination.
class DashboardSidebarFocusScope extends InheritedWidget {
  const DashboardSidebarFocusScope({
    super.key,
    required this.focusNode,
    required this.onMoveToContent,
    required super.child,
  });

  final FocusNode focusNode;
  final VoidCallback onMoveToContent;

  static DashboardSidebarFocusScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DashboardSidebarFocusScope>();
  }

  @override
  bool updateShouldNotify(DashboardSidebarFocusScope oldWidget) =>
      focusNode != oldWidget.focusNode ||
      onMoveToContent != oldWidget.onMoveToContent;
}

/// Sidebar widgets call this to hook into dashboard keyboard navigation.
DashboardSidebarKeyboardScope? dashboardSidebarKeyboardScopeOf(BuildContext context) {
  final scope = DashboardSidebarFocusScope.maybeOf(context);
  if (scope == null) return null;
  return DashboardSidebarKeyboardScope(
    focusNode: scope.focusNode,
    onMoveToContent: scope.onMoveToContent,
  );
}

class DashboardSidebarKeyboardScope {
  const DashboardSidebarKeyboardScope({
    required this.focusNode,
    required this.onMoveToContent,
  });

  final FocusNode focusNode;
  final VoidCallback onMoveToContent;
}
