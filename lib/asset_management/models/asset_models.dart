// Asset Management domain models matching `/api/assets/` JSON shapes.

enum AssetStatus {
  free,
  requestPending,
  engaged,
  returnRequested,
  damaged,
  repair,
  disposed,
  unknown;

  static AssetStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'FREE':
        return AssetStatus.free;
      case 'REQUEST_PENDING':
        return AssetStatus.requestPending;
      case 'ENGAGED':
        return AssetStatus.engaged;
      case 'RETURN_REQUESTED':
        return AssetStatus.returnRequested;
      case 'DAMAGED':
        return AssetStatus.damaged;
      case 'REPAIR':
        return AssetStatus.repair;
      case 'DISPOSED':
        return AssetStatus.disposed;
      default:
        return AssetStatus.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case AssetStatus.free:
        return 'FREE';
      case AssetStatus.requestPending:
        return 'REQUEST_PENDING';
      case AssetStatus.engaged:
        return 'ENGAGED';
      case AssetStatus.returnRequested:
        return 'RETURN_REQUESTED';
      case AssetStatus.damaged:
        return 'DAMAGED';
      case AssetStatus.repair:
        return 'REPAIR';
      case AssetStatus.disposed:
        return 'DISPOSED';
      case AssetStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String get label {
    switch (this) {
      case AssetStatus.free:
        return 'Free';
      case AssetStatus.requestPending:
        return 'Request pending';
      case AssetStatus.engaged:
        return 'Engaged';
      case AssetStatus.returnRequested:
        return 'Return requested';
      case AssetStatus.damaged:
        return 'Damaged';
      case AssetStatus.repair:
        return 'In repair';
      case AssetStatus.disposed:
        return 'Disposed';
      case AssetStatus.unknown:
        return 'Unknown';
    }
  }
}

class AssetActions {
  final bool canRequest;
  final bool canReturn;
  final bool canReportDamage;
  final bool canViewHistory;

  const AssetActions({
    this.canRequest = false,
    this.canReturn = false,
    this.canReportDamage = false,
    this.canViewHistory = true,
  });

  factory AssetActions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssetActions();
    return AssetActions(
      canRequest: json['can_request'] == true,
      canReturn: json['can_return'] == true,
      canReportDamage: json['can_report_damage'] == true,
      canViewHistory: json['can_view_history'] != false,
    );
  }
}

class AssetTimelineEvent {
  final String eventType;
  final String description;
  final String? actorName;
  final DateTime? createdAt;

  const AssetTimelineEvent({
    required this.eventType,
    required this.description,
    this.actorName,
    this.createdAt,
  });

  factory AssetTimelineEvent.fromJson(Map<String, dynamic> json) {
    return AssetTimelineEvent(
      eventType: '${json['event_type'] ?? ''}',
      description: '${json['description'] ?? ''}',
      actorName: json['actor_name']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

class Asset {
  final String assetCode;
  final String name;
  /// Free-text type from the API (e.g. "Laptop", "Standing Desk").
  final String assetType;
  final AssetStatus status;
  final String? brand;
  final String? modelName;
  final String? purchaseDate;
  final String? purchaseCost;
  final String? vendor;
  final String? warrantyExpiry;
  final bool isWarrantyActive;
  final String? department;
  final int? departmentId;
  final String? location;
  final String? qrCode;
  final String? currentAssignee;
  final String? currentAssigneeName;
  final String? previousAssigneeName;
  final List<AssetTimelineEvent> timeline;
  final AssetActions actions;

  const Asset({
    required this.assetCode,
    required this.name,
    required this.assetType,
    required this.status,
    this.brand,
    this.modelName,
    this.purchaseDate,
    this.purchaseCost,
    this.vendor,
    this.warrantyExpiry,
    this.isWarrantyActive = false,
    this.department,
    this.departmentId,
    this.location,
    this.qrCode,
    this.currentAssignee,
    this.currentAssigneeName,
    this.previousAssigneeName,
    this.timeline = const [],
    this.actions = const AssetActions(),
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final timelineRaw = json['timeline'];
    final timeline = <AssetTimelineEvent>[];
    if (timelineRaw is List) {
      for (final item in timelineRaw) {
        if (item is Map) {
          timeline.add(
            AssetTimelineEvent.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final assignee = json['current_assignee'];
    String? assigneeName;
    String? assigneeId;
    if (assignee is Map) {
      assigneeId = '${assignee['id'] ?? ''}';
      final first = '${assignee['first_name'] ?? ''}'.trim();
      final last = '${assignee['last_name'] ?? ''}'.trim();
      final username = '${assignee['username'] ?? ''}'.trim();
      assigneeName = ('$first $last').trim();
      if (assigneeName.isEmpty) assigneeName = username.isEmpty ? null : username;
    } else if (assignee != null) {
      assigneeId = assignee.toString();
    }
    assigneeName ??= json['current_assignee_name']?.toString();

    String? departmentName;
    int? departmentId;
    final dept = json['department'];
    if (dept is Map) {
      departmentId = int.tryParse('${dept['id'] ?? ''}');
      departmentName = '${dept['name'] ?? ''}'.trim();
      if (departmentName.isEmpty) departmentName = null;
    } else if (dept != null) {
      departmentId = int.tryParse('$dept');
      departmentName = json['department_name']?.toString();
    } else {
      departmentName = json['department_name']?.toString();
      departmentId = int.tryParse('${json['department_id'] ?? ''}');
    }

    return Asset(
      assetCode: '${json['asset_code'] ?? json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      assetType: '${json['asset_type'] ?? ''}'.trim(),
      status: AssetStatus.fromApi('${json['status'] ?? ''}'),
      brand: json['brand']?.toString(),
      modelName: json['model_name']?.toString(),
      purchaseDate: json['purchase_date']?.toString(),
      purchaseCost: json['purchase_cost']?.toString(),
      vendor: json['vendor']?.toString(),
      warrantyExpiry: json['warranty_expiry']?.toString(),
      isWarrantyActive: json['is_warranty_active'] == true,
      department: departmentName,
      departmentId: departmentId,
      location: json['location']?.toString(),
      qrCode: json['qr_code']?.toString(),
      currentAssignee: assigneeId,
      currentAssigneeName: assigneeName,
      previousAssigneeName: json['previous_assignee_name']?.toString(),
      timeline: timeline,
      actions: AssetActions.fromJson(
        json['actions'] is Map
            ? Map<String, dynamic>.from(json['actions'] as Map)
            : null,
      ),
    );
  }

  Asset copyWith({AssetActions? actions, List<AssetTimelineEvent>? timeline}) {
    return Asset(
      assetCode: assetCode,
      name: name,
      assetType: assetType,
      status: status,
      brand: brand,
      modelName: modelName,
      purchaseDate: purchaseDate,
      purchaseCost: purchaseCost,
      vendor: vendor,
      warrantyExpiry: warrantyExpiry,
      isWarrantyActive: isWarrantyActive,
      department: department,
      departmentId: departmentId,
      location: location,
      qrCode: qrCode,
      currentAssignee: currentAssignee,
      currentAssigneeName: currentAssigneeName,
      previousAssigneeName: previousAssigneeName,
      timeline: timeline ?? this.timeline,
      actions: actions ?? this.actions,
    );
  }
}

class MyAssetAssignment {
  final String assetCode;
  final String assetName;
  final String assetType;
  final AssetStatus status;
  final String? expectedReturnDate;
  final String? warrantyExpiry;
  final String? qrCode;
  final String? assignedDate;

  const MyAssetAssignment({
    required this.assetCode,
    required this.assetName,
    required this.assetType,
    required this.status,
    this.expectedReturnDate,
    this.warrantyExpiry,
    this.qrCode,
    this.assignedDate,
  });

  factory MyAssetAssignment.fromJson(Map<String, dynamic> json) {
    return MyAssetAssignment(
      assetCode: '${json['asset_code'] ?? ''}',
      assetName: '${json['asset_name'] ?? json['name'] ?? ''}',
      assetType: '${json['asset_type'] ?? ''}'.trim(),
      status: AssetStatus.fromApi('${json['status'] ?? ''}'),
      expectedReturnDate: json['expected_return_date']?.toString(),
      warrantyExpiry: json['warranty_expiry']?.toString(),
      qrCode: json['qr_code']?.toString(),
      assignedDate: json['assigned_date']?.toString(),
    );
  }
}

class AssetRequest {
  final int id;
  final String assetCode;
  final String assetName;
  final String? requesterName;
  final String? purpose;
  final String? expectedReturnDate;
  final String? notes;
  final String? status;
  final DateTime? createdAt;

  const AssetRequest({
    required this.id,
    required this.assetCode,
    required this.assetName,
    this.requesterName,
    this.purpose,
    this.expectedReturnDate,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory AssetRequest.fromJson(Map<String, dynamic> json) {
    final asset = json['asset'];
    String code = '${json['asset_code'] ?? ''}';
    String name = '${json['asset_name'] ?? ''}';
    if (asset is Map) {
      code = code.isEmpty ? '${asset['asset_code'] ?? ''}' : code;
      name = name.isEmpty ? '${asset['name'] ?? ''}' : name;
    }
    final requester = json['requester'] ?? json['employee'] ?? json['user'];
    String? requesterName = json['requester_name']?.toString() ??
        json['employee_name']?.toString();
    if (requesterName == null && requester is Map) {
      final first = '${requester['first_name'] ?? ''}'.trim();
      final last = '${requester['last_name'] ?? ''}'.trim();
      final username = '${requester['username'] ?? ''}'.trim();
      requesterName = ('$first $last').trim();
      if (requesterName.isEmpty) {
        requesterName = username.isEmpty ? null : username;
      }
    }

    return AssetRequest(
      id: int.tryParse('${json['id']}') ?? 0,
      assetCode: code,
      assetName: name,
      requesterName: requesterName,
      purpose: json['purpose']?.toString(),
      expectedReturnDate: json['expected_return_date']?.toString(),
      notes: json['notes']?.toString() ?? json['comment']?.toString(),
      status: json['status']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

class AssetReturnItem {
  final int id;
  final String assetCode;
  final String assetName;
  final String? employeeName;
  final String? expectedReturnDate;
  final DateTime? createdAt;

  const AssetReturnItem({
    required this.id,
    required this.assetCode,
    required this.assetName,
    this.employeeName,
    this.expectedReturnDate,
    this.createdAt,
  });

  factory AssetReturnItem.fromJson(Map<String, dynamic> json) {
    final asset = json['asset'];
    String code = '${json['asset_code'] ?? ''}';
    String name = '${json['asset_name'] ?? ''}';
    if (asset is Map) {
      code = code.isEmpty ? '${asset['asset_code'] ?? ''}' : code;
      name = name.isEmpty ? '${asset['name'] ?? ''}' : name;
    }
    final emp = json['employee'] ?? json['user'] ?? json['assignee'];
    String? empName = json['employee_name']?.toString();
    if (empName == null && emp is Map) {
      final first = '${emp['first_name'] ?? ''}'.trim();
      final last = '${emp['last_name'] ?? ''}'.trim();
      final username = '${emp['username'] ?? ''}'.trim();
      empName = ('$first $last').trim();
      if (empName.isEmpty) empName = username.isEmpty ? null : username;
    }

    return AssetReturnItem(
      id: int.tryParse('${json['id']}') ?? 0,
      assetCode: code,
      assetName: name,
      employeeName: empName,
      expectedReturnDate: json['expected_return_date']?.toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['return_requested_at']),
    );
  }
}

class AssetDamageReport {
  final int id;
  final String assetCode;
  final String assetName;
  final String? description;
  final String? reporterName;
  final String? status;
  final DateTime? createdAt;

  const AssetDamageReport({
    required this.id,
    required this.assetCode,
    required this.assetName,
    this.description,
    this.reporterName,
    this.status,
    this.createdAt,
  });

  factory AssetDamageReport.fromJson(Map<String, dynamic> json) {
    final asset = json['asset'];
    String code = '${json['asset_code'] ?? ''}';
    String name = '${json['asset_name'] ?? ''}';
    if (asset is Map) {
      code = code.isEmpty ? '${asset['asset_code'] ?? ''}' : code;
      name = name.isEmpty ? '${asset['name'] ?? ''}' : name;
    }
    final reporter = json['reporter'] ?? json['reported_by'] ?? json['user'];
    String? reporterName = json['reporter_name']?.toString();
    if (reporterName == null && reporter is Map) {
      final first = '${reporter['first_name'] ?? ''}'.trim();
      final last = '${reporter['last_name'] ?? ''}'.trim();
      final username = '${reporter['username'] ?? ''}'.trim();
      reporterName = ('$first $last').trim();
      if (reporterName.isEmpty) {
        reporterName = username.isEmpty ? null : username;
      }
    }

    return AssetDamageReport(
      id: int.tryParse('${json['id']}') ?? 0,
      assetCode: code,
      assetName: name,
      description: json['description']?.toString(),
      reporterName: reporterName,
      status: json['status']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

enum AssetCalendarColor { green, blue, red }

class AssetCalendarEvent {
  final int? assetId;
  final String assetCode;
  final String assetName;
  final String? employeeName;
  final String? assignedByName;
  final String? assignedDate;
  final String? expectedReturnDate;
  final String? status;
  final AssetCalendarColor color;

  const AssetCalendarEvent({
    this.assetId,
    required this.assetCode,
    required this.assetName,
    this.employeeName,
    this.assignedByName,
    this.assignedDate,
    this.expectedReturnDate,
    this.status,
    this.color = AssetCalendarColor.blue,
  });

  factory AssetCalendarEvent.fromJson(Map<String, dynamic> json) {
    final colorRaw = '${json['color'] ?? 'blue'}'.toLowerCase();
    final color = switch (colorRaw) {
      'green' => AssetCalendarColor.green,
      'red' => AssetCalendarColor.red,
      _ => AssetCalendarColor.blue,
    };

    return AssetCalendarEvent(
      assetId: int.tryParse('${json['asset'] ?? ''}'),
      assetCode: '${json['asset_code'] ?? ''}',
      assetName: '${json['asset_name'] ?? ''}',
      employeeName: json['employee_name']?.toString(),
      assignedByName: json['assigned_by_name']?.toString(),
      assignedDate: json['assigned_date']?.toString(),
      expectedReturnDate: json['expected_return_date']?.toString(),
      status: json['status']?.toString(),
      color: color,
    );
  }
}

class AssetDashboardStats {
  final int total;
  final int free;
  final int engaged;
  final int damaged;
  final int pendingRequests;
  final int returnRequests;
  final int warrantyExpiring;

  const AssetDashboardStats({
    this.total = 0,
    this.free = 0,
    this.engaged = 0,
    this.damaged = 0,
    this.pendingRequests = 0,
    this.returnRequests = 0,
    this.warrantyExpiring = 0,
  });

  factory AssetDashboardStats.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => int.tryParse('$v') ?? 0;
    return AssetDashboardStats(
      total: n(json['total']),
      free: n(json['free']),
      engaged: n(json['engaged']),
      damaged: n(json['damaged']),
      pendingRequests: n(json['pending_requests']),
      returnRequests: n(json['return_requests']),
      warrantyExpiring: n(json['warranty_expiring']),
    );
  }
}

class AssetDepartmentReportRow {
  final int? departmentId;
  final String departmentName;
  final int count;

  const AssetDepartmentReportRow({
    this.departmentId,
    required this.departmentName,
    required this.count,
  });

  factory AssetDepartmentReportRow.fromJson(Map<String, dynamic> json) {
    return AssetDepartmentReportRow(
      departmentId: int.tryParse('${json['department_id'] ?? ''}'),
      departmentName:
          '${json['department__name'] ?? json['department_name'] ?? 'Unknown'}',
      count: int.tryParse('${json['count'] ?? 0}') ?? 0,
    );
  }
}

class AssetEmployeeReportRow {
  final int? assigneeId;
  final String displayName;
  final int count;

  const AssetEmployeeReportRow({
    this.assigneeId,
    required this.displayName,
    required this.count,
  });

  factory AssetEmployeeReportRow.fromJson(Map<String, dynamic> json) {
    final first = '${json['current_assignee__first_name'] ?? ''}'.trim();
    final last = '${json['current_assignee__last_name'] ?? ''}'.trim();
    final username = '${json['current_assignee__username'] ?? ''}'.trim();
    var name = ('$first $last').trim();
    if (name.isEmpty) name = username.isEmpty ? 'Unknown' : username;

    return AssetEmployeeReportRow(
      assigneeId: int.tryParse('${json['current_assignee_id'] ?? ''}'),
      displayName: name,
      count: int.tryParse('${json['count'] ?? 0}') ?? 0,
    );
  }
}

class CreateAssetPayload {
  final String name;
  final String assetType;
  final String? brand;
  final String? modelName;
  final String? purchaseDate;
  final double? purchaseCost;
  final int? departmentId;
  final String? location;

  const CreateAssetPayload({
    required this.name,
    required this.assetType,
    this.brand,
    this.modelName,
    this.purchaseDate,
    this.purchaseCost,
    this.departmentId,
    this.location,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'asset_type': assetType.trim(),
    };
    void put(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) map[key] = value.trim();
    }

    put('brand', brand);
    put('model_name', modelName);
    put('purchase_date', purchaseDate);
    put('location', location);
    if (purchaseCost != null) map['purchase_cost'] = purchaseCost;
    if (departmentId != null) map['department'] = departmentId;
    return map;
  }
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  try {
    return DateTime.parse(raw.toString()).toLocal();
  } catch (_) {
    return null;
  }
}

// ─── Guest access ────────────────────────────────────────────────────────────

class CreateAssetGuestPayload {
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final int expiresInHours;

  const CreateAssetGuestPayload({
    required this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.expiresInHours = 48,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
        if (phoneNumber != null && phoneNumber!.trim().isNotEmpty)
          'phone_number': phoneNumber!.trim(),
        if (address != null && address!.trim().isNotEmpty)
          'address': address!.trim(),
        'expires_in_hours': expiresInHours,
      };
}

class AssetGuestCredentials {
  final String username;
  final String password;
  final DateTime? expiresAt;

  const AssetGuestCredentials({
    required this.username,
    required this.password,
    this.expiresAt,
  });

  factory AssetGuestCredentials.fromJson(Map<String, dynamic> json) {
    return AssetGuestCredentials(
      username: '${json['username'] ?? ''}',
      password: '${json['password'] ?? ''}',
      expiresAt: _parseDateTime(json['expires_at']),
    );
  }
}

enum AssetGuestStatus { active, expired, revoked }

enum AssetGuestRequestStatus { pending, approved, rejected, unknown }

class AssetGuestRequestedAsset {
  final String assetCode;
  final String assetName;
  final AssetGuestRequestStatus status;
  final DateTime? requestedAt;

  const AssetGuestRequestedAsset({
    required this.assetCode,
    required this.assetName,
    required this.status,
    this.requestedAt,
  });

  String get statusLabel => switch (status) {
        AssetGuestRequestStatus.pending => 'Pending',
        AssetGuestRequestStatus.approved => 'Approved',
        AssetGuestRequestStatus.rejected => 'Rejected',
        AssetGuestRequestStatus.unknown => 'Unknown',
      };

  factory AssetGuestRequestedAsset.fromJson(Map<String, dynamic> json) {
    final raw = '${json['status'] ?? ''}'.toUpperCase();
    final status = switch (raw) {
      'PENDING' => AssetGuestRequestStatus.pending,
      'APPROVED' => AssetGuestRequestStatus.approved,
      'REJECTED' => AssetGuestRequestStatus.rejected,
      _ => AssetGuestRequestStatus.unknown,
    };
    return AssetGuestRequestedAsset(
      assetCode: '${json['asset_code'] ?? ''}',
      assetName: '${json['asset_name'] ?? ''}',
      status: status,
      requestedAt: _parseDateTime(json['requested_at']),
    );
  }
}

class AssetGuestAccess {
  final int id;
  final int userId;
  final String username;
  final String name;
  final String? email;
  final String? phoneNumber;
  final bool isActive;
  final String? createdByName;
  final List<AssetGuestRequestedAsset> assets;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const AssetGuestAccess({
    required this.id,
    required this.userId,
    required this.username,
    required this.name,
    this.email,
    this.phoneNumber,
    this.isActive = true,
    this.createdByName,
    this.assets = const [],
    this.expiresAt,
    this.createdAt,
  });

  AssetGuestStatus get status {
    if (!isActive) return AssetGuestStatus.revoked;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) {
      return AssetGuestStatus.expired;
    }
    return AssetGuestStatus.active;
  }

  String get statusLabel => switch (status) {
        AssetGuestStatus.active => 'Active',
        AssetGuestStatus.expired => 'Expired',
        AssetGuestStatus.revoked => 'Revoked',
      };

  /// Prefer phone, else email — shown in full for admin visibility.
  String get contactDisplay {
    final phone = (phoneNumber ?? '').trim();
    if (phone.isNotEmpty) return phone;
    final mail = (email ?? '').trim();
    if (mail.isNotEmpty) return mail;
    return '—';
  }

  bool get isSelfRegistered =>
      createdByName == null || createdByName!.trim().isEmpty;

  factory AssetGuestAccess.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'];
    final assets = <AssetGuestRequestedAsset>[];
    if (rawAssets is List) {
      for (final item in rawAssets) {
        if (item is Map) {
          assets.add(
            AssetGuestRequestedAsset.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return AssetGuestAccess(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      userId: int.tryParse('${json['user'] ?? 0}') ?? 0,
      username: '${json['username'] ?? ''}',
      name: '${json['name'] ?? ''}',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      isActive: json['is_active'] == true || '${json['is_active']}' == 'true',
      createdByName: json['created_by_name']?.toString(),
      assets: assets,
      expiresAt: _parseDateTime(json['expires_at']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}
