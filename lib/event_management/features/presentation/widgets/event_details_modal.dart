import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/constants/app_colors.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/event_remote_datasource_impl.dart';

class EventDetailsModal extends StatelessWidget {
  final EventEntity event;
  final Map<int, UserLite> usersById;
  final void Function(EventEntity) onEdit;
  final void Function(int) onDelete;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.usersById,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(event.eventType);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC), // Ultra light SaaS grey background
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Dynamic Glass Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildHandle()),
                      const SizedBox(height: 20),
                      _buildTopRow(context, tc),
                      const SizedBox(height: 16),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDateSubtitle(),
                    ],
                  ),
                ),
              ),

              // ── The Info Grid ──
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    _buildInfoCard('Time', _fmtTimeRange(), Icons.access_time_filled_rounded),
                    _buildInfoCard('Reminder', '${event.reminderBefore}m early', Icons.notifications_active_rounded),
                  ],
                ),
              ),

              // ── Description & Link (Wide Cards) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (event.description.isNotEmpty)
                        _buildWideCard('Notes', event.description, Icons.notes_rounded),
                      const SizedBox(height: 16),
                      if (event.meetingLink.isNotEmpty)
                        _buildLinkCard(),
                      const SizedBox(height: 24),
                      _buildParticipantSection(),
                      const SizedBox(height: 140), // Space for bottom dock
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── The Floating Action Dock ──
          _buildFloatingDock(context),
        ],
      ),
    );
  }

  // ── UI WIDGETS ───────────────────────────────────────────

  Widget _buildHandle() => Container(
    width: 36, height: 4,
    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
  );

  Widget _buildTopRow(BuildContext context, EventTypeColor tc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: tc.bg.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tc.text.withOpacity(0.2)),
          ),
          child: Text(
            event.eventType.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tc.text, letterSpacing: 1),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSubtitle() {
    return Text(
      DateFormat('EEEE • d MMMM yyyy').format(event.start),
      style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLinkCard() {
    return InkWell(
      onTap: () => _launch(event.meetingLink),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.video_camera_front_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Join Meeting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ATTENDEES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.2)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: event.participants.map((uid) {
              final user = usersById[uid];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(user?.name.isNotEmpty == true ? user!.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ),
                    const SizedBox(height: 6),
                    Text(user?.name.split(' ')[0] ?? 'User', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingDock(BuildContext context) {
    return Positioned(
      bottom: 30, left: 24, right: 24,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark Navy SaaS Dock
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context, event, onDelete),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 20),
                label: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            Container(width: 1, height: 30, color: Colors.white10),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onEdit(event);
                },
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF818CF8), size: 22),
                label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────

  String _fmtTimeRange() => "${DateFormat('h:mm').format(event.start)} - ${DateFormat('h:mm a').format(event.end)}";

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(BuildContext context, EventEntity event, void Function(int) onDelete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Remove Event?', style: TextStyle(color: Colors.white)),
        content: const Text('This will delete the event permanently.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFF87171)))),
        ],
      ),
    );
    if (confirmed == true && event.id != null) {
      onDelete(event.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }
}