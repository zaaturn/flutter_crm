import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/admin_settings/admin_palette.dart';
import 'package:my_app/admin_settings/data/user_admin_repository.dart';
import 'package:my_app/admin_settings/widgets/admin_form.dart';

/// Add a user, or edit one — everything the Django admin "Add user" page had:
/// login, role (employee / admin / super admin), personal details, job
/// details and photo. Superadmin only (the API enforces it too).
class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, this.userId});

  /// `null` to add a new user.
  final int? userId;

  static Future<ManagedUser?> open(BuildContext context, {int? userId}) =>
      Navigator.of(context).push<ManagedUser>(
        MaterialPageRoute(builder: (_) => UserFormScreen(userId: userId)),
      );

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _repo = UserAdminRepository();
  final _form = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _employeeId = TextEditingController();
  final _address = TextEditingController();
  final _designation = TextEditingController();
  final _department = TextEditingController();
  final _designationFocus = FocusNode();
  final _departmentFocus = FocusNode();

  UserFormOptions? _options;
  ManagedUser? _user;
  String _role = 'employee';
  String _gender = '';
  String _workLocation = 'WFO';
  DateTime? _dob;
  DateTime? _doj = DateUtils.dateOnly(DateTime.now());
  Uint8List? _photo;
  String? _photoName;
  bool _removePhoto = false;
  bool _showPassword = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    // The profile card at the top shows the name as it's typed.
    _firstName.addListener(_refreshName);
    _lastName.addListener(_refreshName);
    _load();
  }

  void _refreshName() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [
      _username,
      _password,
      _firstName,
      _lastName,
      _email,
      _phone,
      _employeeId,
      _address,
      _designation,
      _department,
    ]) {
      c.dispose();
    }
    _designationFocus.dispose();
    _departmentFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final options = await _repo.options();
      ManagedUser? user;
      if (_editing) user = await _repo.get(widget.userId!);
      if (!mounted) return;
      setState(() {
        _options = options;
        if (user != null) _fill(user);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _fill(ManagedUser u) {
    _user = u;
    _username.text = u.username;
    _firstName.text = u.firstName;
    _lastName.text = u.lastName;
    _email.text = u.email;
    _phone.text = u.phone;
    _employeeId.text = u.employeeId;
    _address.text = u.address;
    _designation.text = u.designationLabel;
    _department.text = u.departmentLabel;
    _role = u.role;
    _gender = u.gender;
    _workLocation = u.workLocation;
    _dob = u.dateOfBirth;
    _doj = u.dateOfJoining;
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      if (mounted) showAdminSnack(context, 'Photo must be under 5 MB.', error: true);
      return;
    }
    setState(() {
      _photo = bytes;
      _photoName = file.name;
      _removePhoto = false;
    });
  }

  Future<void> _pickDate({required bool birth}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birth ? (_dob ?? DateTime(now.year - 25)) : (_doj ?? now),
      firstDate: DateTime(1940),
      lastDate: birth ? now : DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => birth ? _dob = picked : _doj = picked);
  }

  /// Picked from the list → send its id. Typed something new → send the
  /// name and the server creates it. Blank → clear.
  void _lookup(Map<String, dynamic> fields, String key, String text, List<NamedOption> options) {
    final value = text.trim();
    if (value.isEmpty) {
      fields[key] = '';
      return;
    }
    final match = options.where((o) => o.name.toLowerCase() == value.toLowerCase());
    if (match.isNotEmpty) {
      fields[key] = match.first.id;
    } else {
      fields['${key}_name'] = value;
    }
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final options = _options!;
    setState(() {
      _saving = true;
      _error = null;
    });
    final fields = <String, dynamic>{
      'username': _username.text.trim(),
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone_number': _phone.text.trim(),
      'employee_id': _employeeId.text.trim(),
      'role': _role,
      'gender': _gender,
      'work_location': _workLocation,
      'address': _address.text.trim(),
      'date_of_birth': _dob == null ? '' : UserAdminRepository.iso(_dob!),
      if (_doj != null) 'date_of_joining': UserAdminRepository.iso(_doj!),
      if (!_editing) 'password': _password.text,
      if (_removePhoto) 'remove_photo': true,
    };
    _lookup(fields, 'designation', _designation.text, options.designations);
    _lookup(fields, 'department', _department.text, options.departments);

    try {
      final saved = await _repo.save(
        id: widget.userId,
        fields: fields,
        photo: _photo,
        photoName: _photoName,
      );
      if (!mounted) return;
      showAdminSnack(context, _editing ? 'Saved ${saved.fullName}' : 'Added ${saved.fullName}');
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleActive() async {
    final user = _user!;
    final p = AdminPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate ${user.fullName}?' : 'Reactivate ${user.fullName}?'),
        content: Text(user.isActive
            ? "They'll be logged out everywhere and can't sign in. Their records stay."
            : 'They can sign in again with their existing password.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: user.isActive ? p.danger : p.primary),
            child: Text(user.isActive ? 'Deactivate' : 'Reactivate'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final updated = await _repo.setActive(user.id, !user.isActive);
      if (!mounted) return;
      setState(() => _user = updated);
      showAdminSnack(context, updated.isActive ? 'User reactivated' : 'User deactivated');
    } catch (e) {
      if (mounted) showAdminSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController();
    final p = AdminPalette.of(context);
    // Cancel pops `false`, Update pops the text — hence Object?.
    final result = await showDialog<Object?>(
      context: context,
      builder: (ctx) => AdminFormDialog(
        icon: Icons.lock_reset_rounded,
        title: 'Reset password',
        subtitle: '${_user!.fullName} will be logged out everywhere.',
        primaryLabel: 'Update password',
        onPrimary: () => Navigator.pop(ctx, controller.text),
        children: [
          AdminField(
            label: 'New password',
            required: true,
            helper: 'At least 8 characters, not only numbers.',
            child: TextField(
              controller: controller,
              autofocus: true,
              style: adminFont(color: p.text),
              decoration: adminBox(p, hint: 'Type a new password', icon: Icons.lock_outline_rounded),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result is! String || result.isEmpty) return;
    try {
      final message = await _repo.resetPassword(_user!.id, result);
      if (mounted) showAdminSnack(context, message);
    } catch (e) {
      if (mounted) showAdminSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AdminPalette.of(context);
    return AdminSettingsScaffold(
      title: _editing ? 'Edit user' : 'Add user',
      actions: [
        if (_editing && _user != null)
          PopupMenuButton<String>(
            tooltip: 'More',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) => v == 'password' ? _resetPassword() : _toggleActive(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'password',
                child: Text('Reset password', style: adminFont(color: p.text)),
              ),
              PopupMenuItem(
                value: 'active',
                child: Text(
                  _user!.isActive ? 'Deactivate user' : 'Reactivate user',
                  style: adminFont(color: _user!.isActive ? p.danger : p.primary),
                ),
              ),
            ],
          ),
      ],
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : _options == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AdminErrorBanner(message: _error ?? 'Could not load the form.'),
                  ),
                )
              : _buildForm(p),
    );
  }

  Widget _buildForm(AdminPalette p) {
    final options = _options!;
    final twoCol = p.wide;
    const gap = SizedBox(height: 18);
    Widget pair(Widget a, Widget b) => twoCol
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)],
          )
        : Column(children: [a, gap, b]);
    Widget text(
      TextEditingController c, {
      String? hint,
      IconData? icon,
      TextInputType? keyboard,
      String? Function(String?)? validator,
      TextCapitalization caps = TextCapitalization.none,
      int maxLines = 1,
      bool obscure = false,
      Widget? suffix,
    }) =>
        TextFormField(
          controller: c,
          keyboardType: keyboard,
          validator: validator,
          textCapitalization: caps,
          maxLines: maxLines,
          obscureText: obscure,
          autocorrect: false,
          style: adminFont(color: p.text),
          decoration: adminBox(p, hint: hint, icon: icon, suffix: suffix),
        );

    return Form(
      key: _form,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, p.wide ? 16 : 24),
              children: [
                if (_user != null && !_user!.isActive) ...[
                  const AdminErrorBanner(message: 'This user is deactivated and cannot sign in.'),
                  const SizedBox(height: 12),
                ],
                _profileCard(p),
                _card(p, 'Login', 'How they sign in, and what they can access', [
                  pair(
                    AdminField(
                      label: 'Username',
                      required: true,
                      helper: 'Used to sign in',
                      child: text(
                        _username,
                        hint: 'e.g. asha.rao',
                        icon: Icons.alternate_email_rounded,
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a username' : null,
                      ),
                    ),
                    AdminField(
                      label: 'Role',
                      required: true,
                      helper: _role == 'superadmin'
                          ? 'Can manage every user, module and the holiday list.'
                          : null,
                      child: AdminDropdown<String>(
                        value: options.roles.any((r) => r.value == _role) ? _role : 'employee',
                        items: [
                          for (final r in options.roles)
                            DropdownMenuItem(value: r.value, child: Text(r.label)),
                        ],
                        onChanged: (v) => setState(() => _role = v ?? 'employee'),
                      ),
                    ),
                  ),
                  if (!_editing) ...[
                    gap,
                    AdminField(
                      label: 'Password',
                      required: true,
                      helper: 'At least 8 characters, not only numbers. Share it with them securely.',
                      child: text(
                        _password,
                        hint: 'Create a password',
                        icon: Icons.lock_outline_rounded,
                        obscure: !_showPassword,
                        validator: (v) => (v ?? '').length < 8 ? 'Use at least 8 characters' : null,
                        suffix: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: p.muted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                  ],
                ]),
                _card(p, 'Personal details', null, [
                  pair(
                    AdminField(
                      label: 'First name',
                      required: true,
                      child: text(
                        _firstName,
                        hint: 'e.g. Asha',
                        caps: TextCapitalization.words,
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the first name' : null,
                      ),
                    ),
                    AdminField(
                      label: 'Last name',
                      child: text(_lastName, hint: 'e.g. Rao', caps: TextCapitalization.words),
                    ),
                  ),
                  gap,
                  pair(
                    AdminField(
                      label: 'Email',
                      required: true,
                      child: text(
                        _email,
                        hint: 'name@company.com',
                        icon: Icons.mail_outline_rounded,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Enter an email';
                          return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                              ? null
                              : 'Enter a valid email';
                        },
                      ),
                    ),
                    AdminField(
                      label: 'Mobile number',
                      child: text(
                        _phone,
                        hint: '10-digit number',
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                        validator: (v) {
                          final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                          if (digits.isEmpty) return null;
                          final last10 =
                              digits.length > 10 ? digits.substring(digits.length - 10) : digits;
                          return RegExp(r'^[6-9]\d{9}$').hasMatch(last10)
                              ? null
                              : 'Enter a valid 10-digit mobile number';
                        },
                      ),
                    ),
                  ),
                  gap,
                  pair(
                    AdminField(
                      label: 'Gender',
                      child: AdminDropdown<String>(
                        value: options.genders.any((g) => g.value == _gender) ? _gender : '',
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Not set')),
                          for (final g in options.genders)
                            DropdownMenuItem(value: g.value, child: Text(g.label)),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? ''),
                      ),
                    ),
                    AdminField(
                      label: 'Date of birth',
                      child: AdminDateBox(
                        value: _dob,
                        format: 'd MMM yyyy',
                        onTap: () => _pickDate(birth: true),
                        onClear: () => setState(() => _dob = null),
                      ),
                    ),
                  ),
                  gap,
                  AdminField(
                    label: 'Address',
                    child: text(_address, hint: 'Street, area, city', maxLines: 2),
                  ),
                ]),
                _card(p, 'Job details', null, [
                  pair(
                    AdminField(
                      label: 'Employee ID',
                      child: text(_employeeId, hint: 'e.g. DAX-021', icon: Icons.badge_outlined),
                    ),
                    AdminField(
                      label: 'Date of joining',
                      child: AdminDateBox(
                        value: _doj,
                        format: 'd MMM yyyy',
                        onTap: () => _pickDate(birth: false),
                      ),
                    ),
                  ),
                  gap,
                  pair(
                    AdminField(
                      label: 'Designation',
                      helper: 'Pick one, or type a new one to add it',
                      child: _namedField(
                        p,
                        _designation,
                        _designationFocus,
                        options.designations,
                        hint: 'e.g. Flutter Developer',
                        icon: Icons.work_outline_rounded,
                      ),
                    ),
                    AdminField(
                      label: 'Department',
                      helper: 'Pick one, or type a new one to add it',
                      child: _namedField(
                        p,
                        _department,
                        _departmentFocus,
                        options.departments,
                        hint: 'e.g. Engineering',
                        icon: Icons.apartment_rounded,
                      ),
                    ),
                  ),
                  gap,
                  AdminField(
                    label: 'Work location',
                    child: AdminDropdown<String>(
                      value: options.workLocations.any((w) => w.value == _workLocation)
                          ? _workLocation
                          : (options.workLocations.isNotEmpty
                              ? options.workLocations.first.value
                              : 'WFO'),
                      items: [
                        for (final w in options.workLocations)
                          DropdownMenuItem(value: w.value, child: Text(w.label)),
                      ],
                      onChanged: (v) => setState(() => _workLocation = v ?? 'WFO'),
                    ),
                  ),
                ]),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  AdminErrorBanner(message: _error!),
                ],
              ],
            ),
          ),
          // Pinned, so Save is always one tap away on a long form.
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: p.wide ? p.surface : p.background,
              border: Border(top: BorderSide(color: p.border)),
            ),
            child: Row(
              children: [
                if (p.wide) ...[
                  SizedBox(
                    width: 140,
                    child: AdminButton(
                      label: 'Cancel',
                      outlined: true,
                      onPressed: _saving ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                ],
                Expanded(
                  flex: p.wide ? 0 : 1,
                  child: SizedBox(
                    width: p.wide ? 200 : null,
                    child: AdminButton(
                      label: _editing ? 'Save changes' : 'Add user',
                      icon: _editing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
                      busy: _saving,
                      onPressed: _save,
                      height: 52,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(AdminPalette p, String title, String? subtitle, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionTitle(title, subtitle: subtitle),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  /// Pick an existing designation/department or type a new one.
  Widget _namedField(
    AdminPalette p,
    TextEditingController controller,
    FocusNode focusNode,
    List<NamedOption> options, {
    String? hint,
    IconData? icon,
  }) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        return options.map((o) => o.name).where((n) => q.isEmpty || n.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, textController, node, onSubmit) => TextFormField(
        controller: textController,
        focusNode: node,
        textCapitalization: TextCapitalization.words,
        style: adminFont(color: p.text),
        decoration: adminBox(p, hint: hint, icon: icon),
      ),
      optionsViewBuilder: (context, onSelected, matches) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          color: p.surface,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              children: [
                for (final m in matches)
                  ListTile(
                    dense: true,
                    title: Text(m, style: adminFont(color: p.text)),
                    onTap: () => onSelected(m),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard(AdminPalette p) {
    final existing = _removePhoto ? null : _user?.photoUrl;
    ImageProvider? image;
    if (_photo != null) {
      image = MemoryImage(_photo!);
    } else if (existing != null && existing.isNotEmpty) {
      image = NetworkImage(existing);
    }
    final name = [_firstName.text.trim(), _lastName.text.trim()].where((s) => s.isNotEmpty).join(' ');
    final initials = name.isEmpty
        ? ''
        : name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0].toUpperCase()).join();
    final roleLabel = _options?.roles
            .firstWhere((r) => r.value == _role, orElse: () => const ChoiceOption('', 'Employee'))
            .label ??
        'Employee';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: p.primaryLight,
                  backgroundImage: image,
                  child: image == null
                      ? (name.isEmpty
                          ? Icon(Icons.person_rounded, size: 38, color: p.primary)
                          : Text(initials,
                              style: adminFont(size: 24, weight: FontWeight.w800, color: p.primaryDark)))
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: p.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.surface, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? (_editing ? 'User' : 'New user') : name,
                  style: adminFont(size: 18, weight: FontWeight.w800, color: p.text),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(roleLabel, style: adminFont(size: 12, weight: FontWeight.w700, color: p.primaryDark)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: _pickPhoto,
                      style: TextButton.styleFrom(
                        foregroundColor: p.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(image == null ? 'Upload photo' : 'Change photo',
                          style: adminFont(size: 13, weight: FontWeight.w700)),
                    ),
                    if (image != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _photo = null;
                          _photoName = null;
                          _removePhoto = _user?.photoUrl != null;
                        }),
                        style: TextButton.styleFrom(
                          foregroundColor: p.danger,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: Text('Remove', style: adminFont(size: 13, weight: FontWeight.w700)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
