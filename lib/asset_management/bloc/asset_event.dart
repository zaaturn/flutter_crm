import 'package:equatable/equatable.dart';

import '../models/asset_models.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();
  @override
  List<Object?> get props => [];
}

class AssetShellStarted extends AssetEvent {
  const AssetShellStarted({
    required this.isAdmin,
    this.initialTab,
  });
  final bool isAdmin;
  final AssetShellTab? initialTab;
  @override
  List<Object?> get props => [isAdmin, initialTab];
}

class AssetTabChanged extends AssetEvent {
  const AssetTabChanged(this.tab);
  final AssetShellTab tab;
  @override
  List<Object?> get props => [tab];
}

class AssetRefreshRequested extends AssetEvent {
  const AssetRefreshRequested();
}

class AssetListFilterChanged extends AssetEvent {
  const AssetListFilterChanged({this.status, this.assetType});
  final String? status;
  final String? assetType;
  @override
  List<Object?> get props => [status, assetType];
}

class AssetSearchQueryChanged extends AssetEvent {
  const AssetSearchQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class AssetCreateSubmitted extends AssetEvent {
  const AssetCreateSubmitted(this.payload);
  final CreateAssetPayload payload;
  @override
  List<Object?> get props => [payload];
}

class AssetApproveRequest extends AssetEvent {
  const AssetApproveRequest(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class AssetRejectRequest extends AssetEvent {
  const AssetRejectRequest(this.id, {this.comment});
  final int id;
  final String? comment;
  @override
  List<Object?> get props => [id, comment];
}

class AssetVerifyReturn extends AssetEvent {
  const AssetVerifyReturn(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class AssetRejectReturn extends AssetEvent {
  const AssetRejectReturn(this.id, {this.comment});
  final int id;
  final String? comment;
  @override
  List<Object?> get props => [id, comment];
}

class AssetStartRepair extends AssetEvent {
  const AssetStartRepair(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class AssetCompleteRepair extends AssetEvent {
  const AssetCompleteRepair(this.id, {this.notes});
  final int id;
  final String? notes;
  @override
  List<Object?> get props => [id, notes];
}

class AssetCalendarMonthChanged extends AssetEvent {
  const AssetCalendarMonthChanged(this.year, this.month);
  final int year;
  final int month;
  @override
  List<Object?> get props => [year, month];
}

class AssetSelectionToggled extends AssetEvent {
  const AssetSelectionToggled(this.assetCode);
  final String assetCode;
  @override
  List<Object?> get props => [assetCode];
}

class AssetClearSelection extends AssetEvent {
  const AssetClearSelection();
}

class AssetDeleteRequested extends AssetEvent {
  const AssetDeleteRequested(
    this.assetCode, {
    this.reason,
  });
  final String assetCode;
  final String? reason;
  @override
  List<Object?> get props => [assetCode, reason];
}

enum AssetShellTab {
  dashboard,
  inventory,
  myAssets,
  scan,
  search,
  calendar,
  pendingRequests,
  pendingReturns,
  pendingDamage,
  guests,
}

extension AssetShellTabX on AssetShellTab {
  String get label {
    switch (this) {
      case AssetShellTab.dashboard:
        return 'Dashboard';
      case AssetShellTab.inventory:
        return 'Inventory';
      case AssetShellTab.myAssets:
        return 'My Assets';
      case AssetShellTab.scan:
        return 'Scan QR';
      case AssetShellTab.search:
        return 'Search';
      case AssetShellTab.calendar:
        return 'Calendar';
      case AssetShellTab.pendingRequests:
        return 'Requests';
      case AssetShellTab.pendingReturns:
        return 'Returns';
      case AssetShellTab.pendingDamage:
        return 'Damage';
      case AssetShellTab.guests:
        return 'Guests';
    }
  }
}
