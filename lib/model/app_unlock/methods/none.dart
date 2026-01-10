part of 'method.dart';

/// The none app unlock method provider.
final noneAppUnlockMethodProvider = Provider<NoneAppUnlockMethod>(
  (ref) => NoneAppUnlockMethod._(ref: ref),
);

/// No unlock.
class NoneAppUnlockMethod extends AppUnlockMethod {
  /// The none app unlock method id.
  static const String kMethodId = 'none';

  /// Creates a new none app unlock method instance.
  const NoneAppUnlockMethod._({
    required super.ref,
  }) : super(
         id: kMethodId,
       );

  @override
  Future<Result> _tryUnlock(BuildContext context, UnlockReason reason) => Future.value(const ResultSuccess());

  @override
  AppLockState get defaultAppLockState => AppLockState.unlocked;
}
