import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/delegate.dart';

/// Displays a search button if the TOTP list is available.
class SearchButton extends ConsumerWidget {
  /// Triggered when a TOTP has been found by the user.
  final Function(Totp totp)? onTotpFound;

  /// Creates a new search button instance.
  const SearchButton({
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
            : IconButton(
                onPressed: () async {
                  Totp? result = await TotpSearchDelegate.openDelegate(
                    context,
                    totpList: value,
                  );
                  if (result != null) {
                    onTotpFound?.call(result);
                  }
                },
                icon: const Icon(Icons.search),
              ),
      _ => const SizedBox.shrink(),
    };
  }
}
