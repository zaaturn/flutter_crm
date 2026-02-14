import 'dart:async';
import 'package:flutter/material.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import 'package:my_app/event_management/features/presentation/widgets/device_specific/type_selector_desktop.dart';

import '../../../calendar/data/datasources/event_remote_datasource_impl.dart';


class EventModalDesktop extends StatefulWidget {
  final EventEntity? initialEvent;
  final DateTime? selectedDateTime;
  final void Function(EventEntity) onSave;

  const EventModalDesktop({super.key, this.initialEvent, this.selectedDateTime, required this.onSave});

  @override
  State<EventModalDesktop> createState() => _EventModalState();
}

class _EventModalState extends State<EventModalDesktop> with SingleTickerProviderStateMixin {
  final _ds = EventRemoteDatasourceImpl();
  late final TextEditingController _titleCtrl, _descCtrl, _linkCtrl, _searchCtrl;
  Timer? _debounce;
  List<UserLite> _searchResults = [];
  final Map<int, UserLite> _selectedUsers = {};

  bool _isSearching = false;
  late DateTime _start, _end;
  late String _eventType;
  late List<int> _participants;
  late int _reminderBefore;
  AnimationController? _animCtrl;

  @override
  void initState() {
    super.initState();
    final ev = widget.initialEvent;
    final slot = widget.selectedDateTime;

    _titleCtrl = TextEditingController(text: ev?.title ?? '');
    _descCtrl = TextEditingController(text: ev?.description ?? '');
    _linkCtrl = TextEditingController(text: ev?.meetingLink ?? '');
    _searchCtrl = TextEditingController()..addListener(_onSearchChanged);

    _start = ev?.start ?? slot ?? DateTime.now();
    _end = ev?.end ?? _start.add(const Duration(hours: 1));
    _eventType = ev?.eventType ?? 'meeting';
    _participants = List<int>.from(ev?.participants ?? []);
    _reminderBefore = ev?.reminderBefore ?? 30;

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _linkCtrl.dispose(); _searchCtrl.dispose();
    _debounce?.cancel(); _animCtrl?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _searchUsers(_searchCtrl.text.trim()));
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _ds.searchUser(query);
    setState(() {
      _searchResults = results.where((u) => !_participants.contains(u.id)).toList();
      _isSearching = false;
    });
  }

  bool get _isEditing => widget.initialEvent?.id != null;

  @override
  Widget build(BuildContext context) {
    final animation = _animCtrl != null
        ? CurvedAnimation(parent: _animCtrl!, curve: Curves.easeOutCubic)
        : AlwaysStoppedAnimation(1.0);

    return ScaleTransition(
      scale: animation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 620,
          constraints: const BoxConstraints(maxHeight: 720),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20)),
              const BoxShadow(color: Color(0x1A000000), blurRadius: 80, offset: Offset(0, 40)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.08), Colors.transparent],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Event' : 'Create New Event',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Title', _titleCtrl, hint: 'Event title...', autofocus: true),
                      const SizedBox(height: 20),
                      _label('Event Type'),
                      TypeSelector(selected: _eventType, onChanged: (v) => setState(() => _eventType = v)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Start'),
                          _dateChip(_start, (d) => setState(() => _start = d)),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('End'),
                          _dateChip(_end, (d) => setState(() => _end = d)),
                        ])),
                      ]),
                      const SizedBox(height: 20),
                      _field('Description', _descCtrl, maxLines: 3, hint: 'Add details...'),
                      const SizedBox(height: 20),
                      _field('Meeting Link', _linkCtrl, hint: 'https://meet.google.com/...', icon: Icons.link_rounded),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Reminder'),
                          _reminderDropdown(),
                        ])),
                      ]),
                      const SizedBox(height: 20),
                      _label('Participants'),
                      _participantField(),
                      if (_selectedUsers.isNotEmpty) ...[const SizedBox(height: 12), _chips()],
                    ],
                  ),
                ),
              ),

              // Footer actions
              Container(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      onPressed: _titleCtrl.text.trim().isEmpty ? null : _save,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(_isEditing ? 'Save Changes' : 'Create Event', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
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

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2)),
  );

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, String? hint, IconData? icon, bool autofocus = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        autofocus: autofocus,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.primary) : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 12 : 16, vertical: 14),
        ),
      ),
    ],
  );

  Widget _dateChip(DateTime dt, Function(DateTime) onPick) => InkWell(
    onTap: () async {
      final d = await showDatePicker(context: context, initialDate: dt, firstDate: DateTime(2020), lastDate: DateTime(2100));
      if (d == null || !mounted) return;
      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dt));
      if (t == null || !mounted) return;
      onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(_fmtDT(dt), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    ),
  );

  Widget _reminderDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
    child: DropdownButton<int>(
      value: _reminderBefore,
      isExpanded: true,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      items: const [
        DropdownMenuItem(value: 5, child: Text('5 minutes before')),
        DropdownMenuItem(value: 10, child: Text('10 minutes before')),
        DropdownMenuItem(value: 15, child: Text('15 minutes before')),
        DropdownMenuItem(value: 30, child: Text('30 minutes before')),
        DropdownMenuItem(value: 60, child: Text('1 hour before')),
      ],
      onChanged: (v) => setState(() => _reminderBefore = v!),
    ),
  );

  Widget _participantField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search participants...',
          prefixIcon: const Icon(Icons.person_add_rounded, size: 20, color: AppColors.primary),
          suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      if (_searchResults.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 8),
          constraints: const BoxConstraints(maxHeight: 160),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (_, i) {
              final u = _searchResults[i];
              return ListTile(
                dense: true,
                title: Text(u.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                onTap: () => setState(() {
                  _participants.add(u.id);
                  _selectedUsers[u.id] = u;
                  _searchResults.clear();
                  _searchCtrl.clear();
                }),
              );
            },
          ),
        ),
    ],
  );

  Widget _chips() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _selectedUsers.values.map((u) {
      final initials =
      u.name.isNotEmpty ? u.name[0].toUpperCase() : '?';

      return Chip(
        avatar: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        label: Text(
          u.name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => setState(() {
          _participants.remove(u.id);
          _selectedUsers.remove(u.id);
        }),
        backgroundColor: AppColors.primaryExtraLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }).toList(),
  );


  void _save() {
    widget.onSave(EventEntity(
      id: widget.initialEvent?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      start: _start,
      end: _end,
      meetingLink: _linkCtrl.text.trim(),
      eventType: _eventType,
      participants: _participants,
      reminderBefore: _reminderBefore,
    ));
    Navigator.pop(context);
  }

  String _fmtDT(DateTime dt) {
    final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '${m[dt.month-1]} ${dt.day}, ${dt.year} • $h:$min ${dt.hour >= 12 ? "PM" : "AM"}';
  }
}