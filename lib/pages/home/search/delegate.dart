import 'package:flutter/material.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/extension.dart';
import 'package:open_authenticator/widgets/totp/widget.dart';

/// Allows to search through the TOTP list.
class TotpSearchDelegate extends SearchDelegate<Totp> {
  /// The TOTP list.
  final TotpList totpList;

  /// Creates a new TOTP search delegate instance.
  TotpSearchDelegate({
    required this.totpList,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = super.appBarTheme(context);
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: theme.inputDecorationTheme,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => const BackButton();

  @override
  Widget buildResults(BuildContext context) {
    List<Totp> searchResults = totpList.search(query);
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        Totp totp = searchResults[index];
        return TotpWidget(
          key: ValueKey(totp.uuid),
          totp: totp,
          onTap: (context) => close(context, totp),
        );
      },
      separatorBuilder: (context, position) => const Divider(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  /// Opens the TOTP search delegate.
  static Future<Totp?> openDelegate(
    BuildContext context, {
    required TotpList totpList,
  }) async => await showSearch(
    context: context,
    delegate: TotpSearchDelegate(
      totpList: totpList,
    ),
  );
}
