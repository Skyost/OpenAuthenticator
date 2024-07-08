import 'package:open_authenticator/utils/platform.dart';
import 'package:rate_my_app/rate_my_app.dart';

/// Allows to open the Rate My App dialog only on specific platforms.
class SupportedPlatformsCondition extends Condition with DebuggableCondition {
  /// The supported platforms.
  final List<Platform> supportedPlatforms;

  /// Creates a new supported platforms condition.
  SupportedPlatformsCondition({
    this.supportedPlatforms = const [Platform.android, Platform.iOS, Platform.macOS],
  });

  @override
  bool get isMet => supportedPlatforms.contains(currentPlatform);

  @override
  Map<String, dynamic> get debugMap => {
    'Is platform supported': isMet ? 'Yes' : 'No',
  };
}
