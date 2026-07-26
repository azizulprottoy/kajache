import 'package:get/get.dart';

/// Picks the right language variant for a piece of backend-provided text.
///
/// The kajache API stores Bangla variants (`nameBn`, `titleBn`,
/// `descriptionBn`, `rewordBn`, …) alongside the English fields on some
/// tables (Category, Service, Faq, PaymentMethod, Reward). Use this to render
/// the Bangla value when the app locale is Bangla, falling back to English
/// whenever the Bangla value is missing/empty.
///
/// Reactive by design: `Get.updateLocale` rebuilds the widget tree, so any
/// `build()` that calls this re-evaluates and switches language automatically.
class LocalizedText {
  LocalizedText._();

  static bool get isBengali => Get.locale?.languageCode == 'bn';

  /// Returns [bn] when the locale is Bangla and [bn] is non-empty,
  /// otherwise [en].
  static String pick(String en, String? bn) {
    if (isBengali && bn != null && bn.trim().isNotEmpty) {
      return bn.trim();
    }
    return en.trim();
  }
}
