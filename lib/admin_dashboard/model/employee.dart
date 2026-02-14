
import 'package:flutter/material.dart';
enum LiveStatus { working, breakTime, loggedOut }

class Employee {
  final int id;
  final String username;
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
    required this.username,
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
    return Employee(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      employeeId: json['employee_id'] ?? '',
      phoneNumber: json['phone_number'],
      designation: json['designation'],
      department: json['department'],
      workLocation: json['work_location'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'],
      dateOfJoining: json['date_of_joining'],
      isActive: json['is_active'] ?? true,
      profilePhoto: json['profile_photo'],
      // live fields may or may not be present in list response
      liveStatus: _parseLiveStatus(json['status']),
      checkIn: json['check_in'] ?? '-',
      checkOut: json['check_out'] ?? '-',
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
      username: username,
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
    switch (s) {
      case 'working':
        return LiveStatus.working;
      case 'break':
        return LiveStatus.breakTime;
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