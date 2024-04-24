import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:open_authenticator/utils/validation/sign_in/oauth2.dart';
import 'package:open_authenticator/widgets/countdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Allows to sign in using Github.
class GithubSignIn with OAuth2SignIn {
  @override
  final String clientId;

  /// The login completer.
  Completer<ValidationResult<OAuth2Response>>? _completer;

  /// The retrieved device code.
  String? _deviceCode;

  /// The timer that periodically checks if the login is a success.
  Timer? _checkTimer;

  /// The check interval.
  Duration? _checkInterval;

  /// The timeout timer.
  Timer? _timeoutTimer;

  /// Creates a new Github sign in instance.
  GithubSignIn({
    required this.clientId,
  });

  @override
  String get name => 'Github';

  @override
  Future<ValidationResult<OAuth2Response>> signIn(BuildContext context) async {
    if (_completer != null) {
      return await _completer!.future;
    }
    _completer = Completer<ValidationResult<OAuth2Response>>();
    http.Response response = await http.post(
      Uri.https(
        'github.com',
        '/login/device/code',
        loginUrlParameters,
      ),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode != 200) {
      return ValidationError(
        exception: ValidationException(code: ValidationException.kErrorInvalidResponse),
      );
    }
    Map<String, dynamic> parsedResponse = jsonDecode(response.body);
    String? verificationUrl = parsedResponse['verification_uri'];
    String? userCode = parsedResponse['user_code'];
    if (verificationUrl == null || userCode == null || !(await canLaunchUrlString(verificationUrl))) {
      return ValidationError(
        exception: ValidationException(code: ValidationException.kErrorInvalidResponse),
      );
    }
    Duration timeout = parsedResponse.containsKey('expires_in') ? Duration(seconds: parsedResponse['expires_in']) : const Duration(minutes: 15);
    _timeoutTimer = Timer(
      timeout,
      () => stop(
        context,
        result: const ValidationCancelled(timedOut: true),
      ),
    );
    _deviceCode = parsedResponse['device_code'];
    if (context.mounted) {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(translations.validation.githubCodeDialog.title),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(translations.validation.githubCodeDialog.message),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    userCode,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async => await Clipboard.setData(ClipboardData(text: userCode)),
                    ),
                  ),
                ],
              ),
              Text.rich(
                translations.validation.githubCodeDialog.countdown(
                  countdown: WidgetSpan(
                    child: CountdownWidget(
                      duration: timeout,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
    launchUrlString(verificationUrl);
    _checkInterval = parsedResponse.containsKey('interval') ? Duration(seconds: parsedResponse['interval']) : const Duration(minutes: 5);
    _scheduleCheckTimer(context.mounted ? context : null);
    return await _completer!.future;
  }

  /// Schedules the check timer.
  void _scheduleCheckTimer(BuildContext? context, {Duration additionalDelay = Duration.zero}) {
    _checkTimer?.cancel();
    _checkTimer = null;
    _checkTimer = Timer(
      _checkInterval! + additionalDelay,
      () => _checkForAccessToken(context),
    );
  }

  /// Checks if the user has accepted the login.
  Future<void> _checkForAccessToken(BuildContext? context) async {
    http.Response response = await http.post(
      Uri.https(
        'github.com',
        '/login/oauth/access_token',
        {
          ...loginUrlParameters,
          'device_code': _deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      ),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    Map<String, dynamic> parsedResponse = jsonDecode(response.body);
    if (parsedResponse.containsKey('access_token')) {
      stop(
        context != null && context.mounted ? context : null,
        result: ValidationSuccess(
          object: OAuth2Response(
            accessToken: parsedResponse['access_token'],
          ),
        ),
      );
      return;
    }
    if (parsedResponse['error'] == 'slow_down' && parsedResponse.containsKey('interval')) {
      _scheduleCheckTimer(context != null && context.mounted ? context : null, additionalDelay: Duration(seconds: parsedResponse['interval'] + 1));
    } else {
      _scheduleCheckTimer(context != null && context.mounted ? context : null);
    }
  }

  /// Stops the login.
  Future<void> stop(BuildContext? context, {ValidationResult<OAuth2Response>? result}) async {
    if (context != null && context.mounted) {
      Navigator.pop(context);
    }
    _checkTimer?.cancel();
    _checkTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _deviceCode = null;
    _checkInterval = null;
    _completer?.complete(result ?? const ValidationCancelled());
    _completer = null;
  }

  @override
  List<String> get scopes => [
        'read:user',
        'user:email',
      ];
}
