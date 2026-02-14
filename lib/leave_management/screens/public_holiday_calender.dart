import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/leave_api_services.dart';
import '../models/public_holiday.dart';

class PublicHolidayCalendarScreen extends StatefulWidget {
  const PublicHolidayCalendarScreen({super.key});

  @override
  State<PublicHolidayCalendarScreen> createState() =>
      _PublicHolidayCalendarScreenState();
}

class _PublicHolidayCalendarScreenState
    extends State<PublicHolidayCalendarScreen> with SingleTickerProviderStateMixin {
  final LeaveApiService _apiService = LeaveApiService();

  late int _year;
  bool _loading = true;
  String? _error;
  List<PublicHoliday> _holidays = [];
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.fastOutSlowIn,
    );
    _loadHolidays();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getPublicHolidays(_year);
      setState(() {
        _holidays = data;
      });
      _animationController?.reset();
      _animationController?.forward();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white for a high-end feel
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Calendar",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
        actions: [
          _buildActionChip("$_year"),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error != null
          ? _buildErrorState()
          : FadeTransition(
        opacity: _fadeAnimation!,
        child: _buildTimelineContent(),
      ),
    );
  }

  Widget _buildActionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineContent() {
    final holidaysByMonth = <int, List<PublicHoliday>>{};
    for (var h in _holidays) {
      holidaysByMonth.putIfAbsent(h.date.month, () => []).add(h);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: holidaysByMonth.length,
      itemBuilder: (context, index) {
        final month = holidaysByMonth.keys.elementAt(index);
        final list = holidaysByMonth[month]!;
        return _buildMonthRow(month, list);
      },
    );
  }

  Widget _buildMonthRow(int month, List<PublicHoliday> list) {
    final monthName = DateFormat('MMMM').format(DateTime(_year, month));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Month Indicator
          SizedBox(
            width: 50,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  monthName.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6366F1).withOpacity(0.5), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Holiday Cards
          Expanded(
            child: Column(
              children: list.map((h) => _buildMinimalHolidayCard(h)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHolidayCard(PublicHoliday holiday) {
    final isUpcoming = holiday.date.isAfter(DateTime.now());
    final isToday = DateUtils.isSameDay(holiday.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Date Circle
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isUpcoming ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                holiday.date.day.toString(),
                style: TextStyle(
                  color: isUpcoming ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  DateFormat('EEEE').format(holiday.date),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isUpcoming)
            Container(
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 40, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Sync Error"),
          TextButton(onPressed: _loadHolidays, child: const Text("Retry")),
        ],
      ),
    );
  }
}