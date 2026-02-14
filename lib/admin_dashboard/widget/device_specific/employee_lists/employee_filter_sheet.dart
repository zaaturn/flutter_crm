import 'package:flutter/material.dart';

class EmployeeFilterSheet extends StatefulWidget {
  final List<String> designations;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const EmployeeFilterSheet({
    super.key,
    required this.designations,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<EmployeeFilterSheet> createState() =>
      _EmployeeFilterSheetState();
}

class _EmployeeFilterSheetState
    extends State<EmployeeFilterSheet> {
  String? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final d in widget.designations)
            ListTile(
              title: Text(d),
              trailing: _picked == d
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _picked = _picked == d ? null : d;
                });
              },
            ),
          ElevatedButton(
            onPressed: () {
              widget.onSelected(_picked);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }
}
