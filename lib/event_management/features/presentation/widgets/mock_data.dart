/// Flat mock-user record.  Replace with a real User entity later.
class MockUser {
  final int id;
  final String name;
  final String initials;

  const MockUser({required this.id, required this.name, required this.initials});
}

/// Seed list – mirrors the React version.
const List<MockUser> MOCK_USERS = [
  MockUser(id: 1, name: 'Sarah Chen', initials: 'SC'),
  MockUser(id: 2, name: 'Marcus Rivera', initials: 'MR'),
  MockUser(id: 3, name: 'Priya Patel', initials: 'PP'),
  MockUser(id: 4, name: 'James Okafor', initials: 'JO'),
  MockUser(id: 5, name: 'Elena Vasquez', initials: 'EV'),
  MockUser(id: 6, name: 'David Kim', initials: 'DK'),
  MockUser(id: 7, name: 'Aisha Mohammed', initials: 'AM'),
  MockUser(id: 8, name: 'Tom Bradley', initials: 'TB'),
];

/// Reminder option label ↔ minutes.
const Map<int, String> REMINDER_LABELS = {
  10: '10 minutes before',
  30: '30 minutes before',
  60: '1 hour before',
};

/// Allowed event types.
const List<String> EVENT_TYPES = ['meeting', 'call', 'followup', 'task'];

/// Human-readable labels.
const Map<String, String> EVENT_TYPE_LABELS = {
  'meeting': 'Meeting',
  'call': 'Call',
  'followup': 'Follow-up',
  'task': 'Task',
};

/// Emoji icons matching the React version.
const Map<String, String> EVENT_TYPE_ICONS = {
  'meeting': '📅',
  'call': '📞',
  'followup': '🔄',
  'task': '✅',
};

/// Look up a MockUser by id; returns null when not found.
MockUser? findUser(int id) {
  for (final u in MOCK_USERS) {
    if (u.id == id) return u;
  }
  return null;
}
