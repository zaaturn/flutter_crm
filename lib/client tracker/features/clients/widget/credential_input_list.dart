import 'package:flutter/material.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';

class CredentialInputList extends StatefulWidget {
  final List<Map<String, dynamic>> credentials;
  final VoidCallback onChanged;
  const CredentialInputList({super.key, required this.credentials, required this.onChanged});

  @override
  State<CredentialInputList> createState() => _CredentialInputListState();
}

class _CredentialInputListState extends State<CredentialInputList> {
  void _add() {
    widget.credentials.add({'platform': AppConstants.platforms.first, 'username': '', 'password': ''});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    ...widget.credentials.asMap().entries.map((e) => _CredCard(
      index: e.key,
      cred: e.value,
      onRemove: () { widget.credentials.removeAt(e.key); widget.onChanged(); },
      onUpdate: (k, v) { e.value[k] = v; widget.onChanged(); },
    )),
    const SizedBox(height: 8),
    Align(
      alignment: Alignment.centerLeft,
      child: CrmButton('+ Add Platform', style: BtnStyle.outline, onTap: _add),
    ),
  ]);
}

class _CredCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> cred;
  final VoidCallback onRemove;
  final Function(String, dynamic) onUpdate;
  const _CredCard({required this.index, required this.cred, required this.onRemove, required this.onUpdate});

  @override
  State<_CredCard> createState() => _CredCardState();
}

class _CredCardState extends State<_CredCard> {
  bool _expanded = true;

  static const _platformColors = {
    'youtube':   Color(0xFFFF0000),
    'facebook':  Color(0xFF1877F2),
    'instagram': Color(0xFFE1306C),
    'google_ads':Color(0xFFEA4335),
    'meta_ads':  Color(0xFF0467DF),
    'website':   Color(0xFF0A66C2),
    'other':     Color(0xFF718096),
  };

  @override
  Widget build(BuildContext context) {
    final platform = widget.cred['platform'] as String? ?? AppConstants.platforms.first;
    final dotColor = _platformColors[platform] ?? AppColors.textMuted;
    final label = AppConstants.platformLabels[platform] ?? platform;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: _expanded
                  ? const BorderRadius.vertical(top: Radius.circular(kRadiusSm))
                  : BorderRadius.circular(kRadiusSm),
            ),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMed),
              const Spacer(),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted, size: 20),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onRemove,
                child: const Icon(Icons.close, size: 18, color: AppColors.danger),
              ),
            ]),
          ),
        ),

        if (_expanded)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Platform selector
              CrmDropdown<String>(
                label: 'Platform',
                value: platform,
                items: AppConstants.platforms.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(AppConstants.platformLabels[p] ?? p, style: AppTextStyles.body),
                )).toList(),
                onChanged: (v) { if (v != null) { widget.onUpdate('platform', v); setState(() {}); } },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: CrmTextField(
                  label: 'Username / Email',
                  hint: 'username@email.com',
                  initialValue: widget.cred['username'] as String? ?? '',
                  onChanged: (v) => widget.onUpdate('username', v),
                )),
                const SizedBox(width: 12),
                Expanded(child: CrmTextField(
                  label: 'Password',
                  hint: '••••••••',
                  obscure: true,
                  initialValue: widget.cred['password'] as String? ?? '',
                  onChanged: (v) => widget.onUpdate('password', v),
                )),
              ]),
            ]),
          ),
      ]),
    );
  }
}