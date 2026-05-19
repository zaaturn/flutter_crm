import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/superadmin_repository.dart';

class SuperadminUsersScreen extends StatefulWidget {
  const SuperadminUsersScreen({super.key});

  @override
  State<SuperadminUsersScreen> createState() => _SuperadminUsersScreenState();
}

class _SuperadminUsersScreenState extends State<SuperadminUsersScreen> {
  final _repo = SuperadminRepository();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  _ManageStep _step = _ManageStep.pickEmployee;
  List<Map<String, dynamic>> _users = [];
  bool _loadingList = false;
  bool _loadingAccess = false;
  String? _listError;

  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _accessPayload;

  // Theme: Desktop keeps purple, Mobile uses terracotta.
  bool get _wide => MediaQuery.sizeOf(context).width >= 900;

  Color get _primary => _wide ? const Color(0xFF7C3AED) : const Color(0xFFC05E41);
  Color get _primaryLight => _wide ? const Color(0xFFF5F3FF) : const Color(0xFFEADBC8);
  Color get _primaryDark => _wide ? const Color(0xFF4C1D95) : const Color(0xFF3E2723);
  Color get _textPrimary => _wide ? const Color(0xFF0F172A) : const Color(0xFF3E2723);
  Color get _textMuted => _wide ? const Color(0xFF334155) : const Color(0xFF8D6E63);
  Color get _border =>
      _wide ? const Color(0xFFEDE9FE) : const Color(0xFFC05E41).withValues(alpha: 0.14);
  Color get _bg => _wide ? Colors.white : const Color(0xFFFAF3E0);

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    if (!mounted) return;
    setState(() {
      _loadingList = true;
      _listError = null;
    });
    try {
      final list = await _repo.searchUsers(_searchCtrl.text);
      if (mounted) {
        setState(() {
          _users = list;
          _loadingList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _listError = e.toString();
          _loadingList = false;
        });
      }
    }
  }

  int? _userId(Map<String, dynamic> u) {
    final v = u['id'];
    if (v is int) return v;
    return int.tryParse('$v');
  }

  String _userLabel(Map<String, dynamic> u) {
    return u['name'] ?? u['username'] ?? u['email'] ?? 'User';
  }

  Future<void> _onEmployeeChosen(Map<String, dynamic> user) async {
    final id = _userId(user);
    if (id == null) return;
    setState(() {
      _selectedUser = user;
      _loadingAccess = true;
    });
    try {
      final access = await _repo.getUserAccess(id);
      if (!mounted) return;
      setState(() {
        _accessPayload = access;
        _step = _ManageStep.editAccess;
        _loadingAccess = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingAccess = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load permissions: $e')),
      );
    }
  }

  void _goBackToList() {
    setState(() {
      _step = _ManageStep.pickEmployee;
      _selectedUser = null;
      _accessPayload = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: false,
        leading: _step == _ManageStep.editAccess
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 20),
          onPressed: _goBackToList,
        )
            : null,
        title: Text(
          _step == _ManageStep.pickEmployee ? 'Manage Users' : 'Permission Access',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: _step == _ManageStep.pickEmployee
          ? _buildPickEmployeeBody()
          : _buildAccessBody(),
    );
  }

  Widget _buildPickEmployeeBody() {
    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => _scheduleSearch(),
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name, email, username...',
              hintStyle: GoogleFonts.plusJakartaSans(color: _textMuted, fontWeight: FontWeight.w500),
              prefixIcon: Icon(Icons.search_rounded, color: _primary),
              filled: true,
              fillColor: _primaryLight.withValues(alpha: _wide ? 0.5 : 0.55),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _border, width: 1.5),
              ),
            ),
          ),
        ),
        if (_loadingList) LinearProgressIndicator(backgroundColor: _primaryLight, color: _primary),
        if (_listError != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_listError!, style: const TextStyle(color: Colors.red)),
          ),
        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final u = _users[i];
              return InkWell(
                onTap: _loadingAccess ? null : () => _onEmployeeChosen(u),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border, width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _primaryLight,
                        child: Text(
                          _userLabel(u)[0].toUpperCase(),
                          style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userLabel(u),
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: _textPrimary),
                            ),
                            Text(
                              u['email'] ?? 'No email provided',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _textMuted),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccessBody() {
    final user = _selectedUser;
    final access = _accessPayload;
    if (user == null || access == null) {
      return Center(child: CircularProgressIndicator(color: _primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border, width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _primary,
                  child: const Icon(Icons.shield_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userLabel(user),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: _primaryDark,
                        ),
                      ),
                      Text(
                        'Role Management',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _UserAccessForm(
            userId: _userId(user)!,
            initial: access,
            repository: _repo,
            onSubmitted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _primaryDark,
                  content: Text('Access updated successfully', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ),
              );
              _goBackToList();
            },
          ),
        ],
      ),
    );
  }
}

enum _ManageStep { pickEmployee, editAccess }

class _UserAccessForm extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> initial;
  final SuperadminRepository repository;
  final VoidCallback onSubmitted;

  const _UserAccessForm({
    required this.userId,
    required this.initial,
    required this.repository,
    required this.onSubmitted,
  });

  @override
  State<_UserAccessForm> createState() => _UserAccessFormState();
}

class _UserAccessFormState extends State<_UserAccessForm> {
  late String _role;
  late Map<String, bool> _modules;
  List<String> _moduleKeys = [];
  bool _saving = false;

  bool get _wide => MediaQuery.sizeOf(context).width >= 900;
  Color get _primary => _wide ? const Color(0xFF7C3AED) : const Color(0xFFC05E41);
  Color get _textPrimary => _wide ? const Color(0xFF0F172A) : const Color(0xFF3E2723);
  Color get _border =>
      _wide ? const Color(0xFFEDE9FE) : const Color(0xFFC05E41).withValues(alpha: 0.14);
  Color get _fill =>
      _wide ? Colors.white : Colors.white.withValues(alpha: 0.65);

  @override
  void initState() {
    super.initState();
    _role = (widget.initial['role']?.toString() ?? 'employee').toLowerCase();
    if (!['admin', 'employee', 'client'].contains(_role)) _role = 'employee';

    final rawMods = widget.initial['admin_modules'];
    _modules = Map<String, bool>.from(AuthSession.parseAdminModules(rawMods));

    final avail = widget.initial['available_modules'];
    if (avail is List) {
      _moduleKeys = avail.map((e) => e.toString()).toList();
    } else {
      _moduleKeys = ['employees', 'tasks', 'billing', 'clients', 'payroll', 'leads', 'leave', 'events', 'share', 'assets'];
    }

    for (final k in _moduleKeys) {
      _modules.putIfAbsent(k, () => true);
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.repository.patchUserAccess(
        widget.userId,
        role: _role,
        modules: _role == 'admin' ? _modules : null,
      );
      if (mounted) widget.onSubmitted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'SELECT ACCOUNT ROLE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: _primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _role,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: _textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: _fill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _border),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
            DropdownMenuItem(value: 'employee', child: Text('Employee')),
          ],
          onChanged: (v) { if (v != null) setState(() => _role = v); },
        ),
        if (_role == 'admin') ...[
          const SizedBox(height: 32),
          Text(
            'MODULE PERMISSIONS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: _moduleKeys.map((key) {
                return CheckboxListTile(
                  title: Text(
                    key.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: _textPrimary),
                  ),
                  activeColor: _primary,
                  value: _modules[key] ?? true,
                  onChanged: (b) => setState(() => _modules[key] = b ?? false),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 40),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Text('Update Access', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}