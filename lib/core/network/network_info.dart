import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Repositories call this before every request. The connectivity result
  /// is not a reliable offline signal (VPNs and some Android builds report
  /// `none` while online), so it no longer blocks requests: Dio attempts the
  /// call and `apiErrorMessage` turns a real connection failure into
  /// "Could not reach the server. Check your connection."
  Future<bool> get isConnected async => true;

  /// Advisory only (e.g. for an offline banner). Never use it to skip a
  /// request.
  Future<bool> get hasNetworkInterface async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
