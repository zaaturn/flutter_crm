import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/dashboards/data/datasource/user_remote_datasource.dart';
import 'package:my_app/dashboards/data/repositories_impl/user_repository_impl.dart';
import 'package:my_app/dashboards/domain/models/department_model.dart';
import 'package:my_app/services/api_client.dart';

import '../../bloc/asset_bloc.dart';
import '../../bloc/asset_event.dart';
import '../../bloc/asset_state.dart';
import '../../models/asset_models.dart';
import '../../repository/asset_repository.dart';
import '../../theme/asset_theme.dart';
import '../../utils/asset_file_download.dart';

class AssetCreateScreen extends StatefulWidget {
  const AssetCreateScreen({super.key, this.useMobileTheme = false});

  final bool useMobileTheme;

  @override
  State<AssetCreateScreen> createState() => _AssetCreateScreenState();
}

class _AssetCreateScreenState extends State<AssetCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _type = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _cost = TextEditingController();
  final _location = TextEditingController();

  DateTime? _purchaseDate;
  List<DepartmentModel> _departments = const [];
  int? _departmentId;
  bool _loadingDepartments = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final repo = UserRepositoryImpl(UserRemoteDataSource(ApiClient()));
      final list = await repo.getDepartments();
      if (!mounted) return;
      setState(() {
        _departments = list;
        _loadingDepartments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDepartments = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _brand.dispose();
    _model.dispose();
    _cost.dispose();
    _location.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final costRaw = _cost.text.trim();
    final cost = costRaw.isEmpty ? null : double.tryParse(costRaw);

    final payload = CreateAssetPayload(
      name: _name.text.trim(),
      assetType: _type.text.trim(),
      brand: _brand.text,
      modelName: _model.text,
      purchaseDate: _purchaseDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_purchaseDate!),
      purchaseCost: cost,
      departmentId: _departmentId,
      location: _location.text,
    );
    context.read<AssetBloc>().add(AssetCreateSubmitted(payload));
  }

  Future<void> _showCreatedQr(Asset asset) async {
    final mint = !widget.useMobileTheme;
    final accent =
        mint ? AssetDesktopTheme.teal : AssetMobileTheme.terracotta;
    final repo = AssetRepository();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Asset created',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  asset.assetCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (asset.qrCode != null && asset.qrCode!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: asset.qrCode!,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.qr_code_2,
                        size: 120,
                        color: accent,
                      ),
                    ),
                  )
                else
                  Icon(Icons.qr_code_2, size: 120, color: accent),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final bytes =
                                await repo.downloadQrPng(asset.assetCode);
                            if (!ctx.mounted) return;
                            await downloadAssetFile(
                              ctx,
                              bytes: bytes,
                              filename: '${asset.assetCode}-qr.png',
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download QR'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            final bytes =
                                await repo.downloadLabelPdf(asset.assetCode);
                            if (!ctx.mounted) return;
                            await downloadAssetFile(
                              ctx,
                              bytes: bytes,
                              filename: '${asset.assetCode}-label.pdf',
                            );
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(backgroundColor: accent),
                        icon: const Icon(Icons.print),
                        label: const Text('Print label'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mint = !widget.useMobileTheme;
    final accent =
        mint ? AssetDesktopTheme.teal : AssetMobileTheme.terracotta;

    return BlocListener<AssetBloc, AssetState>(
      listenWhen: (p, c) =>
          p.lastCreatedAsset != c.lastCreatedAsset ||
          p.error != c.error,
      listener: (context, state) async {
        final created = state.lastCreatedAsset;
        if (created != null) {
          await _showCreatedQr(created);
          if (!context.mounted) return;
          Navigator.pop(context, true);
          return;
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            mint ? AssetDesktopTheme.shellMint : AssetMobileTheme.cream,
        appBar: AppBar(
          backgroundColor:
              mint ? Colors.white : AssetMobileTheme.terracotta,
          foregroundColor: mint ? AssetDesktopTheme.textDark : Colors.white,
          title: Text(
            'Create asset',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _field(_name, 'Asset Name *', required: true),
              const SizedBox(height: 12),
              _field(
                _type,
                'Asset Type *',
                required: true,
                hint: 'e.g. Laptop, Monitor, Standing Desk',
              ),
              const SizedBox(height: 12),
              _field(_brand, 'Brand'),
              const SizedBox(height: 12),
              _field(_model, 'Model'),
              const SizedBox(height: 12),
              _dateRow(
                label: 'Purchase Date',
                value: _purchaseDate,
                onPick: (d) => setState(() => _purchaseDate = d),
              ),
              const SizedBox(height: 12),
              _field(
                _cost,
                'Purchase Cost',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _field(_location, 'Location'),
              const SizedBox(height: 12),
              if (_loadingDepartments)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<int?>(
                  initialValue: _departmentId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._departments.map(
                      (d) => DropdownMenuItem<int?>(
                        value: d.id,
                        child: Text(d.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _departmentId = v),
                ),
              const SizedBox(height: 24),
              BlocBuilder<AssetBloc, AssetState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.actionLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: state.actionLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create asset'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? keyboard,
    String? hint,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateRow({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPick,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_today_outlined),
      label: Text(
        value == null
            ? label
            : '$label: ${DateFormat('yyyy-MM-dd').format(value)}',
      ),
    );
  }
}
