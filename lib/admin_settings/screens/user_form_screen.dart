import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_app/admin_settings/admin_palette.dart';
import 'package:my_app/admin_settings/data/user_admin_repository.dart';

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
    _load();
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
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set a new password'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: p.input('New password', helper: 'At least 8 characters. They will be logged out.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: FilledButton.styleFrom(backgroundColor: p.primary),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password == null || password.isEmpty) return;
    try {
      final message = await _repo.resetPassword(_user!.id, password);
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
            onSelected: (v) => v == 'password' ? _resetPassword() : _toggleActive(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'password', child: Text('Reset password')),
              PopupMenuItem(
                value: 'active',
                child: Text(_user!.isActive ? 'Deactivate user' : 'Reactivate user'),
              ),
            ],
          ),
      ],
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.primary))
          : _options == null
              ? Center(child: Text(_error ?? 'Could not load the form.', style: TextStyle(color: p.danger)))
              : _buildForm(p),
    );
  }

  Widget _buildForm(AdminPalette p) {
    final options = _options!;
    final twoCol = p.wide;
    Widget pair(Widget a, Widget b) => twoCol
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)],
          )
        : Column(children: [a, const SizedBox(height: 12), b]);
    const gap = SizedBox(height: 12);

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_user != null && !_user!.isActive)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This user is deactivated and cannot sign in.',
                style: TextStyle(color: p.danger, fontWeight: FontWeight.w700),
              ),
            ),
          _photoPicker(p),
          _section(p, 'Login'),
          pair(
            TextFormField(
              controller: _username,
              decoration: p.input('Username *', helper: 'Used to sign in'),
              autocorrect: false,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a username' : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: options.roles.any((r) => r.value == _role) ? _role : 'employee',
              decoration: p.input('Role *'),
              items: [
                for (final r in options.roles) DropdownMenuItem(value: r.value, child: Text(r.label)),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'employee'),
            ),
          ),
          if (_role == 'superadmin') ...[
            gap,
            Text(
              'Super admins can manage every user, every module and the holiday list.',
              style: TextStyle(color: p.muted, fontSize: 12),
            ),
          ],
          if (!_editing) ...[
            gap,
            TextFormField(
              controller: _password,
              obscureText: !_showPassword,
              decoration: p.input(
                'Password *',
                helper: 'At least 8 characters, not only numbers. Share it with them securely.',
                suffix: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: (v) => (v ?? '').length < 8 ? 'Use at least 8 characters' : null,
            ),
          ],
          _section(p, 'Personal details'),
          pair(
            TextFormField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              decoration: p.input('First name *'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the first name' : null,
            ),
            TextFormField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              decoration: p.input('Last name'),
            ),
          ),
          gap,
          pair(
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: p.input('Email *'),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Enter an email';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                    ? null
                    : 'Enter a valid email';
              },
            ),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: p.input('Mobile number', hint: '10 digits'),
              validator: (v) {
                final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                if (digits.isEmpty) return null;
                final last10 = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
                return RegExp(r'^[6-9]\d{9}$').hasMatch(last10)
                    ? null
                    : 'Enter a valid 10-digit mobile number';
              },
            ),
          ),
          gap,
          pair(
            DropdownButtonFormField<String>(
              initialValue: options.genders.any((g) => g.value == _gender) ? _gender : '',
              decoration: p.input('Gender'),
              items: [
                const DropdownMenuItem(value: '', child: Text('Not set')),
                for (final g in options.genders) DropdownMenuItem(value: g.value, child: Text(g.label)),
              ],
              onChanged: (v) => setState(() => _gender = v ?? ''),
            ),
            _dateField(p, 'Date of birth', _dob, () => _pickDate(birth: true),
                onClear: () => setState(() => _dob = null)),
          ),
          gap,
          TextFormField(
            controller: _address,
            maxLines: 2,
            maxLength: 255,
            decoration: p.input('Address'),
          ),
          _section(p, 'Job details'),
          pair(
            TextFormField(
              controller: _employeeId,
              decoration: p.input('Employee ID', hint: 'e.g. DAX-021'),
            ),
            _dateField(p, 'Date of joining', _doj, () => _pickDate(birth: false)),
          ),
          gap,
          pair(
            _namedField(p, 'Designation', _designation, _designationFocus, options.designations),
            _namedField(p, 'Department', _department, _departmentFocus, options.departments),
          ),
          gap,
          DropdownButtonFormField<String>(
            initialValue: options.workLocations.any((w) => w.value == _workLocation)
                ? _workLocation
                : (options.workLocations.isNotEmpty ? options.workLocations.first.value : null),
            decoration: p.input('Work location'),
            items: [
              for (final w in options.workLocations)
                DropdownMenuItem(value: w.value, child: Text(w.label)),
            ],
            onChanged: (v) => setState(() => _workLocation = v ?? 'WFO'),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: p.danger, fontWeight: FontWeight.w700)),
            ),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _editing ? 'Save changes' : 'Add user',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(AdminPalette p, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: p.primary,
          ),
        ),
      );

  Widget _dateField(
    AdminPalette p,
    String label,
    DateTime? value,
    VoidCallback onTap, {
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: p.input(
          label,
          suffix: value != null && onClear != null
              ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClear)
              : const Icon(Icons.calendar_month_rounded),
        ),
        child: Text(
          value == null ? 'Select' : DateFormat('d MMM yyyy').format(value),
          style: TextStyle(color: value == null ? p.muted : p.text),
        ),
      ),
    );
  }

  /// Pick an existing designation/department or type a new one.
  Widget _namedField(
    AdminPalette p,
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    List<NamedOption> options,
  ) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        return options.map((o) => o.name).where((n) => q.isEmpty || n.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmit) => TextFormField(
        controller: textController,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.words,
        decoration: p.input(label, helper: 'Pick one, or type a new one to add it'),
      ),
      optionsViewBuilder: (context, onSelected, matches) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final m in matches)
                  ListTile(dense: true, title: Text(m), onTap: () => onSelected(m)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoPicker(AdminPalette p) {
    final existing = _removePhoto ? null : _user?.photoUrl;
    ImageProvider? image;
    if (_photo != null) {
      image = MemoryImage(_photo!);
    } else if (existing != null && existing.isNotEmpty) {
      image = NetworkImage(existing);
    }
    final initials = (_firstName.text.isNotEmpty ? _firstName.text[0] : '?').toUpperCase();
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickPhoto,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: p.primaryLight,
              backgroundImage: image,
              child: image == null
                  ? Text(
                      initials,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: p.primaryDark),
                    )
                  : null,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(image == null ? 'Add photo' : 'Change photo'),
                style: TextButton.styleFrom(foregroundColor: p.primaryDark),
              ),
              if (image != null)
                TextButton(
                  onPressed: () => setState(() {
                    _photo = null;
                    _photoName = null;
                    _removePhoto = _user?.photoUrl != null;
                  }),
                  style: TextButton.styleFrom(foregroundColor: p.danger),
                  child: const Text('Remove'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
