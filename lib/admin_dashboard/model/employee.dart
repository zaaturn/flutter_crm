import 'package:flutter/material.dart';

enum LiveStatus { working, breakTime, loggedOut }

class Employee {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String? phoneNumber;
  final String? designation;
  final String? department;
  final String? workLocation;
  final String? address;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final bool isActive;
  final String? profilePhoto;

  final LiveStatus liveStatus;
  final String checkIn;
  final String checkOut;

  const Employee({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeId,
    this.phoneNumber,
    this.designation,
    this.department,
    this.workLocation,
    this.address,
    this.dateOfBirth,
    this.dateOfJoining,
    this.isActive = true,
    this.profilePhoto,
    this.liveStatus = LiveStatus.loggedOut,
    this.checkIn = '-',
    this.checkOut = '-',
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  bool get isOnline => liveStatus != LiveStatus.loggedOut;

  String get statusText {
    switch (liveStatus) {
      case LiveStatus.working:
        return 'Working';
      case LiveStatus.breakTime:
        return 'On Break';
      case LiveStatus.loggedOut:
        return 'Logged Out';
    }
  }

  Color get statusColor {
    switch (liveStatus) {
      case LiveStatus.working:
        return Colors.green;
      case LiveStatus.breakTime:
        return Colors.orange;
      case LiveStatus.loggedOut:
        return Colors.redAccent;
    }
  }

  IconData get statusIcon {
    switch (liveStatus) {
      case LiveStatus.working:
        return Icons.circle;
      case LiveStatus.breakTime:
        return Icons.pause_circle;
      case LiveStatus.loggedOut:
        return Icons.cancel;
    }
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    bool truthy(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y';
    }

    final onBreak = truthy(json['on_break']) ||
        truthy(json['is_on_break']) ||
        truthy(json['is_break']) ||
        truthy(json['break']) ||
        truthy(json['break_time']) ||
        truthy(json['onBreak']);
    return Employee(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      workLocation: json['work_location']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      dateOfJoining: json['date_of_joining']?.toString(),
      isActive: json['is_active'] ?? true,
      profilePhoto: json['profile_photo']?.toString(),
      liveStatus:
          onBreak ? LiveStatus.breakTime : _parseLiveStatus(json['status']),
      checkIn: json['check_in']?.toString() ?? '-',
      checkOut: json['check_out']?.toString() ?? '-',

    );
  }

  Employee copyWith({
    LiveStatus? liveStatus,
    String? checkIn,
    String? checkOut,
    bool? isActive,
    String? profilePhoto,
  }) {
    return Employee(
      id: id,
      name: name,
      firstName: firstName,
      lastName: lastName,
      email: email,
      employeeId: employeeId,
      phoneNumber: phoneNumber,
      designation: designation,
      department: department,
      workLocation: workLocation,
      address: address,
      dateOfBirth: dateOfBirth,
      dateOfJoining: dateOfJoining,
      isActive: isActive ?? this.isActive,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      liveStatus: liveStatus ?? this.liveStatus,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
    );
  }

  static LiveStatus _parseLiveStatus(dynamic s) {
    final v = s?.toString().trim().toLowerCase();
    switch (v) {
      case 'working':
      case 'work':
      case 'checked_in':
      case 'checkin':
      case 'online':
        return LiveStatus.working;
      case 'break':
      case 'on_break':
      case 'break_time':
      case 'paused':
        return LiveStatus.breakTime;
      case 'loggedout':
      case 'logged_out':
      case 'logout':
      case 'checked_out':
      case 'checkout':
      case 'offline':
        return LiveStatus.loggedOut;
      default:
        return LiveStatus.loggedOut;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Employee && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Employee(id: $id, name: $fullName, status: $statusText)';
}
