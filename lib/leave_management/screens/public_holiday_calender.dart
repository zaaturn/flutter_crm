import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/leave_holiday_repository.dart';
import '../widgets/leave_holiday_month_calendar.dart';

class PublicHolidayCalendarScreen extends StatefulWidget {
  const PublicHolidayCalendarScreen({super.key});

  @override
  State<PublicHolidayCalendarScreen> createState() =>
      _PublicHolidayCalendarScreenState();
}

class _PublicHolidayCalendarScreenState
    extends State<PublicHolidayCalendarScreen> {
  static const _bg = Color(0xFFFAF3E0);
  static const _terracotta = Color(0xFFC05E41);
  static const _textDark = Color(0xFF3E2723);
  static const _textMuted = Color(0xFF8D6E63);

  final LeaveHolidayRepository _repository = LeaveHolidayRepository();

  late int _year;
  late int _month;
  bool _loadingYear = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadYear();
  }

  Future<void> _loadYear() async {
    setState(() {
      _loadingYear = true;
      _error = null;
    });
    try {
      LeaveHolidayRepository.clearYear(_year);
      await _repository.loadYear(_year, forceRefresh: true);
      if (!mounted) return;
      setState(() => _loadingYear = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingYear = false;
      });
    }
  }

  void _changeYear(int delta) {
    setState(() {
      _year += delta;
      _month = 1;
    });
    _loadYear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
          style: const TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: _textMuted),
            onPressed: () => _changeYear(-1),
          ),
          _buildActionChip('$_year'),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: _textMuted),
            onPressed: () => _changeYear(1),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loadingYear
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _terracotta,
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x33C05E41)),
          ),
          child: LeaveHolidayMonthCalendar(
            key: ValueKey('$_year-$_month'),
            year: _year,
            month: _month,
            holidayRepository: _repository,
            onMonthChanged: (year, month) {
              if (year != _year) {
                setState(() => _year = year);
                _loadYear();
              } else if (month != _month) {
                setState(() => _month = month);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = index + 1;
          final selected = month == _month;
          final label = DateFormat('MMM').format(DateTime(_year, month));

          return ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: selected ? Colors.white : _textDark,
              ),
            ),
            selected: selected,
            onSelected: (_) => setState(() => _month = month),
            selectedColor: _terracotta,
            backgroundColor: const Color(0xFFEADBC8),
            side: BorderSide(
              color: selected ? _terracotta : const Color(0x33C05E41),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
        },
      ),
    );
  }

  Widget _buildActionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEADBC8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33C05E41)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
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
          const Text('Sync Error'),
          TextButton(onPressed: _loadYear, child: const Text('Retry')),
        ],
      ),
    );
  }
}
