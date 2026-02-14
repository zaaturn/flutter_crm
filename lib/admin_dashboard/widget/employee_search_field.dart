import 'package:flutter/material.dart';
import '../model/user.dart';

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
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<User>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: (u) => u.displayName,
      optionsBuilder: (value) {
        final q = value.text.toLowerCase();
        if (q.isEmpty) return widget.users;
        return widget.users.where(
              (u) =>
          u.username.toLowerCase().contains(q) ||
              u.displayName.toLowerCase().contains(q),
        );
      },
      onSelected: (u) {
        widget.controller.text = u.displayName;
        widget.onSelected(u);
        _focusNode.unfocus();
      },
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: "Select an employee...",
            prefixIcon: Icon(Icons.person_outline),
            suffixIcon: Icon(Icons.keyboard_arrow_down),
            border: InputBorder.none,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options
                .map(
                  (u) => ListTile(
                title: Text(u.displayName),
                subtitle: Text(u.username),
                onTap: () => onSelected(u),
              ),
            )
                .toList(),
          ),
        );
      },
    );
  }
}






