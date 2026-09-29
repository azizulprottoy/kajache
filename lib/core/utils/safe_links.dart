import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// URL schemes the app is willing to hand to the OS.
const _launchableSchemes = {'http', 'https', 'mailto', 'tel'};

/// Parses [url] and returns it only if its scheme is http, https, mailto or
/// tel. Server-provided links with any other scheme (intent:, file:,
/// javascript:, custom app schemes) are rejected.
Uri? safeLaunchUri(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !_launchableSchemes.contains(uri.scheme.toLowerCase())) {
    return null;
  }
  if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isEmpty) {
    return null;
  }
  return uri;
}

/// Launches [url] externally if [safeLaunchUri] accepts it.
/// Returns false when the link was rejected or could not be opened.
Future<bool> launchSafeUrl(String url) async {
  final uri = safeLaunchUri(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Navigation policy for in-app web pages: only pages on the same host as
/// [allowedUrl] load inside the WebView. Other http(s)/mailto/tel links open
/// in the system app; everything else is blocked.
NavigationDecision webNavigationDecision(
  NavigationRequest request,
  String allowedUrl,
) {
  final target = Uri.tryParse(request.url);
  final allowed = Uri.tryParse(allowedUrl);
  if (target == null || allowed == null) return NavigationDecision.prevent;

  final scheme = target.scheme.toLowerCase();
  if (scheme == 'about' || scheme == 'data') {
    return request.isMainFrame
        ? NavigationDecision.prevent
        : NavigationDecision.navigate;
  }

  final sameSite = (scheme == 'http' || scheme == 'https') &&
      target.host.toLowerCase() == allowed.host.toLowerCase();
  if (sameSite) return NavigationDecision.navigate;

  if (request.isMainFrame) launchSafeUrl(request.url);
  return NavigationDecision.prevent;
}
