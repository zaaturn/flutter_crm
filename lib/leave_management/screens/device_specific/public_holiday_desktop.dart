import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// PROPER PACKAGE IMPORTS
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/models/public_holiday.dart';

class PublicHolidayCalendarScreenDesktop extends StatefulWidget {
  const PublicHolidayCalendarScreenDesktop({super.key});

  @override
  State<PublicHolidayCalendarScreenDesktop> createState() =>
      _PublicHolidayCalendarScreenState();
}

class _PublicHolidayCalendarScreenState
    extends State<PublicHolidayCalendarScreenDesktop> with SingleTickerProviderStateMixin {
  final LeaveApiService _apiService = LeaveApiService();

  late int _year;
  bool _loading = true;
  String? _error;
  List<PublicHoliday> _holidays = [];

  // Desktop Design Tokens (Static const to allow use in UI)
  static const Color _bgSlate = Color(0xFFF8FAFC);
  static const Color _borderSlate = Color(0xFFE2E8F0);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _textMain = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getPublicHolidays(_year);
      if (mounted) {
        setState(() {
          _holidays = data;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 1100;

    return Scaffold(
      backgroundColor: _bgSlate,
      appBar: _buildDesktopAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _indigo))
          : _error != null
          ? _buildErrorState()
          : _buildDesktopContent(isWide),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        "Company Holidays",
        style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w800,
            fontSize: 20
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _borderSlate, height: 1),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() => _year--);
            _loadHolidays();
          },
        ),
        _buildActionChip("$_year"),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() => _year++);
            _loadHolidays();
          },
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildDesktopContent(bool isWide) {
    final holidaysByMonth = <int, List<PublicHoliday>>{};
    for (var h in _holidays) {
      holidaysByMonth.putIfAbsent(h.date.month, () => []).add(h);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 20, vertical: 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDesktopHeader(holidaysByMonth.length),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : (MediaQuery.of(context).size.width > 700 ? 2 : 1),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  mainAxisExtent: 320,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final list = holidaysByMonth[month] ?? [];
                  return _buildMonthGridCard(month, list);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(int count) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Annual Schedule",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _textMain,
                  letterSpacing: -1
              ),
            ),
            Text(
              "Total of $count company-wide holidays for the year $_year",
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {},

          icon: const Icon(Icons.event_available, size: 18),
          label: const Text("Sync to Calendar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _textMain,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _borderSlate),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGridCard(int month, List<PublicHoliday> holidays) {
    final monthName = DateFormat('MMMM').format(DateTime(_year, month));
    final bool hasHolidays = holidays.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSlate),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textMain
                  ),
                ),
                if (hasHolidays)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      "${holidays.length} Holiday${holidays.length > 1 ? 's' : ''}",
                      style: const TextStyle(
                          color: _indigo,
                          fontSize: 11,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: _borderSlate),
          Expanded(
            child: hasHolidays
                ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: holidays.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildMinimalHolidayTile(holidays[index]),
            )
                : Center(
              child: Text(
                  "No holidays",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHolidayTile(PublicHoliday holiday) {
    final isUpcoming = holiday.date.isAfter(DateTime.now());

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isUpcoming ? _indigo : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              holiday.date.day.toString(),
              style: TextStyle(
                color: isUpcoming ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holiday.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textMain
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat('EEEE').format(holiday.date),
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: _bgSlate,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderSlate)
      ),
      child: Text(
          label,
          style: const TextStyle(color: _textMain, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: _borderSlate),
          const SizedBox(height: 16),
          const Text(
              "Unable to sync calendar data",
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          TextButton(
              onPressed: _loadHolidays,
              child: const Text("Retry Connection")
          ),
        ],
      ),
    );
  }
}