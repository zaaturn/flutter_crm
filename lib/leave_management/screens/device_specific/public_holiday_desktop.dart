import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/models/public_holiday.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';
import 'package:my_app/leave_management/services/leave_holiday_repository.dart';
import 'package:my_app/leave_management/widgets/leave_holiday_month_calendar.dart';

class PublicHolidayCalendarScreenDesktop extends StatefulWidget {
  const PublicHolidayCalendarScreenDesktop({super.key});

  @override
  State<PublicHolidayCalendarScreenDesktop> createState() =>
      _PublicHolidayCalendarScreenState();
}

class _PublicHolidayCalendarScreenState
    extends State<PublicHolidayCalendarScreenDesktop> {
  final LeaveHolidayRepository _repository = LeaveHolidayRepository();

  late int _year;
  late int _month;
  bool _loadingYear = true;
  String? _error;
  List<PublicHoliday> _yearHolidays = [];

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
      final data = await _repository.loadYear(_year, forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _yearHolidays = data;
        _loadingYear = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
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

  void _selectMonth(int month) {
    setState(() => _month = month);
  }

  int get _holidaysThisMonth =>
      _yearHolidays.where((h) => h.date.month == _month).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            LeaveV2TopBar(
              title: 'Holiday Calendar',
              actions: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: EmployeeDashboardV2Theme.textDark,
                  onPressed: () => _changeYear(-1),
                ),
                _buildYearChip('$_year'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: EmployeeDashboardV2Theme.textDark,
                  onPressed: () => _changeYear(1),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Expanded(
              child: _loadingYear
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                        strokeWidth: 2,
                      ),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LeaveV2PageTitle(
                title: DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
                subtitle:
                    '$_holidaysThisMonth public holiday${_holidaysThisMonth == 1 ? '' : 's'} · ${_yearHolidays.length} total in $_year',
              ),
              const SizedBox(height: 20),
              _buildMonthSelector(),
              const SizedBox(height: 20),
              LeaveV2ContentCard(
                padding: const EdgeInsets.all(20),
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
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = index + 1;
          final selected = month == _month;
          final count =
              _yearHolidays.where((h) => h.date.month == month).length;
          final label = DateFormat('MMM').format(DateTime(_year, month));

          return ChoiceChip(
            label: Text(
              count > 0 ? '$label ($count)' : label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: selected
                    ? Colors.white
                    : EmployeeDashboardV2Theme.textDark,
              ),
            ),
            selected: selected,
            onSelected: (_) => _selectMonth(month),
            selectedColor: EmployeeDashboardV2Theme.greenMid,
            backgroundColor: EmployeeDashboardV2Theme.cardMuted,
            side: BorderSide(
              color: selected
                  ? EmployeeDashboardV2Theme.greenMid
                  : EmployeeDashboardV2Theme.cardBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }

  Widget _buildYearChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: EmployeeDashboardV2Theme.greenLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: EmployeeDashboardV2Theme.green.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: EmployeeDashboardV2Theme.textDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: EmployeeDashboardV2Theme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to sync calendar data',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          if (_error != null && _error!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ),
          ],
          TextButton(
            onPressed: _loadYear,
            child: Text(
              'Retry Connection',
              style: GoogleFonts.plusJakartaSans(
                color: EmployeeDashboardV2Theme.greenMid,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
