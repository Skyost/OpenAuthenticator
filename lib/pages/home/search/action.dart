import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/route.dart';
import 'package:open_authenticator/widgets/clickable.dart';

/// Displays a search button if the TOTP list is available.
class SearchAction extends ConsumerWidget {
  /// Triggered when a TOTP has been found by the user.
  final Function(Totp totp)? onTotpFound;

  /// Creates a new search button instance.
  const SearchAction({
    super.key,
    this.onTotpFound,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<TotpList> totps = ref.watch(totpRepositoryProvider);
    return switch (totps) {
      AsyncData<TotpList>(:final value) =>
        value.isEmpty
            ? const SizedBox.shrink()
            : ClickableHeaderAction(
                onPress: () async {
                  Totp? result = await showTotpSearch(context);
                  if (result != null) {
                    onTotpFound?.call(result);
                  }
                },
                icon: const Icon(FIcons.search),
              ),
      _ => const SizedBox.shrink(),
    };
  }
}
