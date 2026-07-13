import 'app_constants.dart';

class MediaUrlHelper {
  MediaUrlHelper._();

  static String resolve(String? url) {
    if (url == null || url.trim().isEmpty) return '';

    final rawUrl = url.trim();

    final mediaBaseUrl = AppConstants.baseUrl.replaceFirst(
      RegExp(r'/api/v\d+/?$'),
      '',
    );


    if (rawUrl.startsWith('http://localhost:3000')) {
      return rawUrl.replaceFirst('http://localhost:3000', mediaBaseUrl);
    }

    if (rawUrl.startsWith('/')) {
      return '$mediaBaseUrl$rawUrl';
    }

    return rawUrl;
  }
}