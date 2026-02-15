import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStateProvider = AsyncNotifierProvider<ConnectivityStateNotifier, bool>(ConnectivityStateNotifier.new);

class ConnectivityStateNotifier extends AsyncNotifier<bool> {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> build() async {
    StreamSubscription<List<ConnectivityResult>>? subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    ref.onDispose(subscription.cancel);

    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    return result.firstOrNull != ConnectivityResult.none;
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) => state = AsyncData(result.firstOrNull != ConnectivityResult.none);
}
