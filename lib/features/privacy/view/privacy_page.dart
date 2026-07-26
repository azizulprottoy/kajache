import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/utils/translation_keys.dart';
import '../../../shared/widgets/common_app_bar.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final WebViewController _controller;
  final RxBool _isLoading = true.obs;
  final RxBool _hasError = false.obs;

  /// Language the currently-loaded page was requested in.
  String _loadedLang = '';

  String get _lang => LocalizedText.isBengali ? 'bn' : 'en';

  String _localizedUrl() {
    const base = AppConstants.privacyUrl;
    final separator = base.contains('?') ? '&' : '?';
    return '$base${separator}lang=$_lang';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _hasError.value = false;
            _isLoading.value = true;
          },
          onPageFinished: (_) => _isLoading.value = false,
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              _hasError.value = true;
              _isLoading.value = false;
            }
          },
        ),
      );
    _load();
  }

  void _load() {
    _loadedLang = _lang;
    _hasError.value = false;
    _isLoading.value = true;
    _controller.loadRequest(Uri.parse(_localizedUrl()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Locale switched while open → reload in the new language.
    if (_loadedLang != _lang) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CommonAppBar(
        title: TKeys.privacyPolicy.tr,
        showBack: true,
        showLanguageToggle: true,
      ),
      body: Obx(() {
        if (_hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    TKeys.failedToLoadPage.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: Text(TKeys.retry.tr),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }
}
