import 'package:get/get.dart';

import 'bn_bangla.dart';
import 'en_english.dart';


class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'bn_BD': bnBD,
  };
}