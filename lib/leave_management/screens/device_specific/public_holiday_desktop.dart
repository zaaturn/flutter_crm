import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/models/public_holiday.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

class PublicHolidayCalendarScreenDesktop extends StatefulWidget {
  const PublicHolidayCalendarScreenDesktop({super.key});

  @override
  State<PublicHolidayCalendarScreenDesktop> createState() =>
      _PublicHolidayCalendarScreenState();
}

class _PublicHolidayCalendarScreenState
    extends State<PublicHolidayCalendarScreenDesktop> {
  final LeaveApiService _apiService = LeaveApiService();

  late int _year;
  bool _loading = true;
  String? _error;
  List<PublicHoliday> _holidays = [];

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
        setState(() => _holidays = data);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 1100;

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
                  onPressed: () {
                    setState(() => _year--);
                    _loadHolidays();
                  },
                ),
                _buildYearChip('$_year'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: EmployeeDashboardV2Theme.textDark,
                  onPressed: () {
                    setState(() => _year++);
                    _loadHolidays();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                        strokeWidth: 2,
                      ),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : _buildDesktopContent(isWide),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContent(bool isWide) {
    final holidaysByMonth = <int, List<PublicHoliday>>{};
    for (var h in _holidays) {
      holidaysByMonth.putIfAbsent(h.date.month, () => []).add(h);
    }

    final monthsWithHolidays = holidaysByMonth.length;

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
                title: 'Annual Schedule',
                subtitle:
                    'Total of $monthsWithHolidays months with company holidays for $_year',
              ),
              const SizedBox(height: 20),
              LeaveV2KpiGrid(
                aspectRatioWide: 2.6,
                aspectRatioNarrow: 2.0,
                items: [
                  LeaveV2KpiData(
                    value: '${_holidays.length}',
                    label: 'Holidays',
                    tag: '$_year',
                    color: const Color(0xFF9333EA),
                    icon: Icons.calendar_month_rounded,
                  ),
                  LeaveV2KpiData(
                    value: '$monthsWithHolidays',
                    label: 'Active months',
                    tag: 'Calendar',
                    color: EmployeeDashboardV2Theme.greenMid,
                    icon: Icons.event_available_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide
                      ? 3
                      : (MediaQuery.of(context).size.width > 700 ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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

  Widget _buildMonthGridCard(int month, List<PublicHoliday> holidays) {
    final monthName = DateFormat('MMMM').format(DateTime(_year, month));
    final bool hasHolidays = holidays.isNotEmpty;

    return LeaveV2ContentCard(
      padding: EdgeInsets.zero,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                ),
                if (hasHolidays)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: EmployeeDashboardV2Theme.greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${holidays.length} Holiday${holidays.length > 1 ? 's' : ''}',
                      style: GoogleFonts.plusJakartaSans(
                        color: EmployeeDashboardV2Theme.greenMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: EmployeeDashboardV2Theme.rowBorder),
          Expanded(
            child: hasHolidays
                ? ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: holidays.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildMinimalHolidayTile(holidays[index]),
                  )
                : Center(
                    child: Text(
                      'No holidays',
                      style: GoogleFonts.plusJakartaSans(
                        color: EmployeeDashboardV2Theme.textMuted,
                        fontSize: 13,
                      ),
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
            color: isUpcoming
                ? EmployeeDashboardV2Theme.greenMid
                : EmployeeDashboardV2Theme.slateBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              holiday.date.day.toString(),
              style: GoogleFonts.plusJakartaSans(
                color: isUpcoming
                    ? Colors.white
                    : EmployeeDashboardV2Theme.textBody,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EmployeeDashboardV2Theme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateFormat('EEEE').format(holiday.date),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
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
            onPressed: _loadHolidays,
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
