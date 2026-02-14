import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/user.dart';

class EmployeeSearchField extends StatefulWidget {
  final List<User> users;
  final TextEditingController controller;
  final ValueChanged<User?> onSelected;

  const EmployeeSearchField({
    super.key,
    required this.users,
    required this.controller,
    required this.onSelected,
  });

  @override
  State<EmployeeSearchField> createState() => _EmployeeSearchFieldState();
}

class _EmployeeSearchFieldState extends State<EmployeeSearchField> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D3199);

    // Using User instead of dynamic fixes the type bound error
    return RawAutocomplete<User>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: (User u) => u.displayName,
      optionsBuilder: (TextEditingValue value) {
        final q = value.text.toLowerCase();
        if (q.isEmpty) return widget.users;
        return widget.users.where(
              (u) =>
          u.username.toLowerCase().contains(q) ||
              u.displayName.toLowerCase().contains(q),
        );
      },
      onSelected: (User u) {
        widget.controller.text = u.displayName;
        widget.onSelected(u);
        _focusNode.unfocus();
      },
      // --- FIELD VIEW ---
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus ? primaryBlue : Colors.grey.shade200,
              width: focusNode.hasFocus ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Search employee...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.person_search_outlined,
                  size: 20, color: focusNode.hasFocus ? primaryBlue : Colors.grey),
              suffixIcon: const Icon(Icons.expand_more, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      },
      // --- OPTIONS OVERLAY ---
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              width: 320, // Desktop specific width
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final User user = options.elementAt(index);
                  return _EmployeeOptionTile(
                    user: user,
                    onTap: () => onSelected(user),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeOptionTile extends StatefulWidget {
  final User user;
  final VoidCallback onTap;

  const _EmployeeOptionTile({required this.user, required this.onTap});

  @override
  State<_EmployeeOptionTile> createState() => _EmployeeOptionTileState();
}

class _EmployeeOptionTileState extends State<_EmployeeOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Initials Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0D3199).withOpacity(0.1),
                child: Text(
                  widget.user.displayName[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3199)
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E293B)
                      ),
                    ),
                    Text(
                      "@${widget.user.username}",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}