import 'package:my_app/leave_management/models/public_holiday.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

/// Caches full-year holiday payloads for fast month switching.
class LeaveHolidayRepository {
  LeaveHolidayRepository([LeaveApiService? api])
      : _api = api ?? LeaveApiService();

  final LeaveApiService _api;
  static final Map<int, List<PublicHoliday>> _yearCache = {};

  Future<List<PublicHoliday>> loadYear(int year, {bool forceRefresh = false}) async {
    if (!forceRefresh && _yearCache.containsKey(year)) {
      return _yearCache[year]!;
    }
    final holidays = await _api.getPublicHolidays(year);
    if (holidays.isNotEmpty) {
      _yearCache[year] = holidays;
    } else {
      _yearCache.remove(year);
    }
    return holidays;
  }

  Future<List<PublicHoliday>> holidaysForMonth(
    int year,
    int month, {
    bool forceRefresh = false,
  }) async {
    final yearList = await loadYear(year, forceRefresh: forceRefresh);
    return yearList.where((h) => h.date.month == month).toList();
  }

  PublicHoliday? holidayOn(DateTime day, List<PublicHoliday> holidays) {
    for (final h in holidays) {
      if (h.date.year == day.year &&
          h.date.month == day.month &&
          h.date.day == day.day) {
        return h;
      }
    }
    return null;
  }

  Map<DateTime, PublicHoliday> holidaysByDate(List<PublicHoliday> holidays) {
    final map = <DateTime, PublicHoliday>{};
    for (final h in holidays) {
      map[DateTime(h.date.year, h.date.month, h.date.day)] = h;
    }
    return map;
  }

  static void clearCache() => _yearCache.clear();

  static void clearYear(int year) => _yearCache.remove(year);
}
