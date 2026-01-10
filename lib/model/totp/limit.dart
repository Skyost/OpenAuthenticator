import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/totp/repository.dart';

/// The TOTP limit provider.
final totpLimitProvider = FutureProvider<TotpLimit>((ref) async {
  StorageType storageType = await ref.watch(storageTypeSettingsEntryProvider.future);
  ContributorPlanState contributorPlanState = await ref.watch(contributorPlanStateProvider.future);
  TotpList totps = await ref.watch(totpRepositoryProvider.future);
  return TotpLimit(
    storageType: storageType,
    contributorPlanState: contributorPlanState,
    currentTotpCount: totps.length,
  );
});

/// The class that allows to check whether TOTP limit has been reached.
class TotpLimit {
  /// The storage type.
  final StorageType storageType;

  /// The contributor plan state.
  final ContributorPlanState contributorPlanState;

  /// The current TOTP count.
  final int currentTotpCount;

  /// Creates a new TOTP limit instance.
  const TotpLimit({
    required this.storageType,
    required this.contributorPlanState,
    required this.currentTotpCount,
  });

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  bool _willExceedIfAddMore({
    int count = 1,
    StorageType? storageType,
  }) {
    if (storageType == StorageType.localOnly) {
      return false;
    }

    int limit = contributorPlanState == ContributorPlanState.active ? App.contributorTotpsLimit : App.defaultTotpsLimit;
    return currentTotpCount + count > limit;
  }

  /// Returns whether the limit will be exceeded if one more TOTP is added.
  bool willExceedIfAddMore({int count = 1}) => _willExceedIfAddMore(
    count: count,
  );

  /// Returns whether the user should be able to change the current storage type.
  bool canChangeStorageType(StorageType currentStorageType) {
    if (currentStorageType == StorageType.shared) {
      return true;
    }
    return !_willExceedIfAddMore(
      count: 0,
      storageType: currentStorageType == StorageType.shared ? StorageType.localOnly : StorageType.shared,
    );
  }

  /// Returns whether the TOTP limit is exceeded.
  bool get isExceeded => willExceedIfAddMore(count: 0);
}
