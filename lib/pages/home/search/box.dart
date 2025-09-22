import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/delegate.dart';

/// A widget that allows to search for a TOTP.
class SearchBoxWidget extends ConsumerStatefulWidget implements PreferredSizeWidget {
  /// Triggered when a TOTP has been found by the user.
  final Function(Totp totp)? onTotpFound;

  /// Creates a new search box instance.
  const SearchBoxWidget({
    super.key,
    this.onTotpFound,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchBoxWidgetState();
}

/// The search box widget state.
class _SearchBoxWidgetState extends ConsumerState<SearchBoxWidget> {
  /// The current focus node.
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: TextField(
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: InputBorder.none,
        icon: Icon(Icons.search),
      ),
    ),
  );

  /// Triggered when the focus changes.
  void onFocusChange() async {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
      TotpList totpList = await ref.read(totpRepositoryProvider.future);
      if (mounted) {
        Totp? result = await TotpSearchDelegate.openDelegate(
          context,
          totpList: totpList,
        );
        if (result != null) {
          widget.onTotpFound?.call(result);
        }
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
