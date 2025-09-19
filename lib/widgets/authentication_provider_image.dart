import 'package:flutter/material.dart';
import 'package:open_authenticator/model/authentication/providers/apple.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/model/authentication/providers/github.dart';
import 'package:open_authenticator/model/authentication/providers/google.dart';
import 'package:open_authenticator/model/authentication/providers/microsoft.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/providers/twitter.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';

/// The image of a [FirebaseAuthenticationProvider].
class FirebaseAuthenticationProviderImage extends StatelessWidget {
  /// The provider instance.
  final FirebaseAuthenticationProvider provider;

  /// The width.
  final double? width;

  /// The height.
  final double? height;

  /// Creates a new Firebase authentication provider image instance.
  const FirebaseAuthenticationProviderImage({
    super.key,
    required this.provider,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) => SizedScalableImageWidget(
    asset: switch (provider) {
      EmailLinkAuthenticationProvider() => 'assets/images/authentication/email.si',
      GoogleAuthenticationProvider() => 'assets/images/authentication/google.si',
      AppleAuthenticationProvider() => 'assets/images/authentication/apple.si',
      GithubAuthenticationProvider() => 'assets/images/authentication/github.si',
      MicrosoftAuthenticationProvider() => 'assets/images/authentication/microsoft.si',
      TwitterAuthenticationProvider() => 'assets/images/authentication/x.si',
      _ => 'assets/images/logo.si',
    },
    width: width,
    height: width,
  );
}
