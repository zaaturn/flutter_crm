import 'package:flutter/material.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
class ServiceInputList extends StatefulWidget {
  final List<String> services;
  final VoidCallback onChanged;
  const ServiceInputList({super.key, required this.services, required this.onChanged});

  @override
  State<ServiceInputList> createState() => _ServiceInputListState();
}

class _ServiceInputListState extends State<ServiceInputList> {
  final _ctrl = TextEditingController();

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    widget.services.add(val);
    _ctrl.clear();
    widget.onChanged();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (widget.services.isNotEmpty) ...[
      Wrap(
        spacing: 8, runSpacing: 8,
        children: widget.services.asMap().entries.map((e) =>
            _ServiceTag(label: e.value, onRemove: () {
              widget.services.removeAt(e.key);
              widget.onChanged();
            }),
        ).toList(),
      ),
      const SizedBox(height: 14),
    ],
    Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          style: AppTextStyles.body,
          onSubmitted: (_) => _add(),
          decoration: InputDecoration(
            hintText: 'Type service name and press Add…',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusSm), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusSm), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      CrmButton('Add', onTap: _add),
    ]),
  ]);
}

class _ServiceTag extends StatefulWidget {
  final String label;
  final VoidCallback onRemove;
  const _ServiceTag({required this.label, required this.onRemove});

  @override
  State<_ServiceTag> createState() => _ServiceTagState();
}

class _ServiceTagState extends State<_ServiceTag> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..forward();
    _scale = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.label, style: AppTextStyles.small.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: widget.onRemove,
          child: const Icon(Icons.close, size: 14, color: AppColors.primary),
        ),
      ]),
    ),
  );
}