import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/event_remote_datasource_impl.dart';
import 'type_selector.dart';

class EventModal extends StatefulWidget {
  final EventEntity? initialEvent;
  final DateTime? selectedDateTime;
  final Map<int, UserLite> usersById;
  final void Function(EventEntity) onSave;

  const EventModal({
    super.key,
    this.initialEvent,
    this.selectedDateTime,
    required this.usersById,
    required this.onSave,
  });

  @override
  State<EventModal> createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _linkCtrl;
  late DateTime _start;
  late DateTime _end;
  late String _eventType;

  // ✅ Storing the full Participant objects
  late List<Participant> _participants;
  late int _reminderBefore;

  Timer? _debounce;
  static const Color brandIndigo = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    final ev = widget.initialEvent;
    _titleCtrl = TextEditingController(text: ev?.title ?? '');
    _descCtrl = TextEditingController(text: ev?.description ?? '');
    _linkCtrl = TextEditingController(text: ev?.meetingLink ?? '');
    _start = ev?.start ?? widget.selectedDateTime ?? DateTime.now();
    _end = ev?.end ?? _start.add(const Duration(hours: 1));
    _eventType = ev?.eventType ?? 'meeting';

    // ✅ Initialize with Participant objects
    _participants = List<Participant>.from(ev?.participants ?? []);
    _reminderBefore = ev?.reminderBefore ?? 30;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _sectionTitle("EVENT TITLE"),
                _greyCard(
                  child: TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 16),
                    decoration: const InputDecoration(hintText: 'e.g. Strategy Meeting', border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle("EVENT TYPE"),
                TypeSelector(selected: _eventType, onChanged: (v) => setState(() => _eventType = v)),
                const SizedBox(height: 24),
                _sectionTitle("SCHEDULE"),
                _greyCard(
                  child: Row(
                    children: [
                      Expanded(child: _timePicker(_start, "FROM", (v) => setState(() => _start = v))),
                      Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                      Expanded(child: _timePicker(_end, "TO", (v) => setState(() => _end = v))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle("DESCRIPTION"),
                _greyCard(
                  child: TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Add notes...', border: InputBorder.none)),
                ),
                const SizedBox(height: 24),
                _sectionTitle("MEETING LINK"),
                _greyCard(
                  child: TextField(
                    controller: _linkCtrl,
                    style: const TextStyle(fontSize: 14, color: brandIndigo, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(icon: Icon(Icons.link, size: 20, color: brandIndigo), hintText: 'https://meet.google.com/abc', border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle("PARTICIPANTS"),
                _buildParticipantSelector(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildActionDock(),
        ],
      ),
    );
  }

  Widget _buildParticipantSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showSearchModal(context),
          borderRadius: BorderRadius.circular(16),
          child: _greyCard(
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.person_add_alt_1_rounded, color: brandIndigo),
              title: Text("Add Employees", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              trailing: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_participants.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _participants.map((person) {
              return InputChip(
                label: Text(person.name, style: const TextStyle(fontSize: 12)),
                onDeleted: () => setState(() => _participants.removeWhere((p) => p.id == person.id)),
                backgroundColor: const Color(0xFFEEF2FF),
                labelStyle: const TextStyle(color: brandIndigo, fontWeight: FontWeight.bold),
                deleteIconColor: brandIndigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide.none,
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showSearchModal(BuildContext context) {
    final dataSource = EventRemoteDatasourceImpl();
    List<UserLite> filtered = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  TextField(
                    autofocus: true,
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), () async {
                        final query = value.trim();
                        if (query.isEmpty) {
                          setModalState(() { filtered = []; isSearching = false; });
                          return;
                        }
                        setModalState(() => isSearching = true);
                        final results = await dataSource.searchUser(query);
                        setModalState(() { filtered = results; isSearching = false; });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search employees...",
                      prefixIcon: const Icon(Icons.search, color: brandIndigo),
                      suffixIcon: isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        if (_participants.any((p) => p.id == user.id)) return const SizedBox.shrink();

                        return ListTile(
                          leading: CircleAvatar(backgroundColor: const Color(0xFFEEF2FF), child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: brandIndigo, fontWeight: FontWeight.bold))),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          onTap: () {
                            // ✅ FIXED: Using empty string for email since UserLite doesn't have it
                            final newParticipant = Participant(
                              id: user.id,
                              name: user.name,
                              email: '',
                            );
                            setState(() => _participants.add(newParticipant));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Row(
        children: [
          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _titleCtrl.text.isEmpty ? null : () {
                widget.onSave(EventEntity(
                    id: widget.initialEvent?.id,
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim(),
                    start: _start,
                    end: _end,
                    meetingLink: _linkCtrl.text.trim(),
                    eventType: _eventType,
                    participants: _participants,
                    reminderBefore: _reminderBefore
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: brandIndigo, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(widget.initialEvent == null ? "Create Event" : "Update Event", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _greyCard({required Widget child}) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))), child: child);
  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: brandIndigo, letterSpacing: 1.2)));
  Widget _buildDragHandle() => Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)));
  Widget _buildHeader() => Row(children: [Text(widget.initialEvent == null ? "New Event" : "Edit Event", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF94A3B8)))]);
  Widget _timePicker(DateTime dt, String label, ValueChanged<DateTime> onPick) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(context: context, initialDate: dt, firstDate: DateTime.now(), lastDate: DateTime(2030));
      if (d == null) return;
      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dt));
      if (t == null) return;
      onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
    },
    child: Column(children: [Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))), const SizedBox(height: 4), Text(DateFormat('hh:mm a').format(dt), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: brandIndigo)), Text(DateFormat('MMM d, yyyy').format(dt), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))]),
  );
}