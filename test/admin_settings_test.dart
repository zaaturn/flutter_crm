import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/admin_settings/data/holiday_admin_repository.dart';
import 'package:my_app/admin_settings/data/user_admin_repository.dart';

void main() {
  test('holiday parses the API shape', () {
    final h = AdminHoliday.fromJson({
      'id': 4,
      'date': '2026-11-01',
      'name': 'Rajyotsava',
      'local_name': '',
      'day': 'Sunday',
    });
    expect(h.id, 4);
    expect(h.date, DateTime(2026, 11, 1));
    expect(h.day, 'Sunday');
  });

  test('import preview reads counts, errors and rows', () {
    final r = HolidayImportResult({
      'dry_run': true,
      'created': 2,
      'updated': 1,
      'removed': 0,
      'valid_rows': 3,
      'errors': [
        {'line': 4, 'error': "'x' is not a date. Use YYYY-MM-DD."},
      ],
      'holidays': [
        {'date': '2026-01-26', 'name': 'Republic Day', 'local_name': ''},
      ],
      'detail': 'Would add 2, update 1. 1 row(s) skipped.',
    });
    expect(r.dryRun, isTrue);
    expect((r.created, r.updated, r.validRows), (2, 1, 3));
    expect(r.errors.single.line, 4);
    expect(r.holidays.single.name, 'Republic Day');
  });

  test('managed user labels super admins and reads lookups', () {
    final u = ManagedUser({
      'id': 7,
      'username': 'asha',
      'full_name': 'Asha Rao',
      'role': 'superadmin',
      'is_active': true,
      'department': 2,
      'department_label': 'Engineering',
      'designation': null,
      'date_of_birth': '1995-04-12',
      'date_of_joining': null,
    });
    expect(u.roleLabel, 'Super admin');
    expect(u.departmentId, 2);
    expect(u.designationId, isNull);
    expect(u.dateOfBirth, DateTime(1995, 4, 12));
    expect(u.dateOfJoining, isNull);
  });

  test('form options parse every list', () {
    final o = UserFormOptions.fromJson({
      'roles': [
        {'value': 'employee', 'label': 'Employee'},
        {'value': 'superadmin', 'label': 'Super admin'},
      ],
      'genders': [
        {'value': 'female', 'label': 'Female'},
      ],
      'work_locations': [
        {'value': 'WFO', 'label': 'Work From Office'},
      ],
      'departments': [
        {'id': 1, 'name': 'Sales'},
      ],
      'designations': [],
    });
    expect(o.roles.map((r) => r.value), ['employee', 'superadmin']);
    expect(o.departments.single.name, 'Sales');
    expect(o.designations, isEmpty);
  });
}
