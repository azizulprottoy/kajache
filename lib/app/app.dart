import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/controller/local_controller.dart';
import '../core/controller/theme_controller.dart';
import '../core/utils/app_translations.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_themes.dart';

class KajAcheApp extends StatelessWidget {
  const KajAcheApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController  = Get.put(ThemeController(),  permanent: true);
    Get.put(LocaleController(), permanent: true);

    return GetMaterialApp(
      title: 'Kaj Ache',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations:   AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('bn', 'BD'),
      ],

      theme:        AppThemes.light,
      darkTheme:    AppThemes.dark,
      themeMode:    themeController.themeMode,
      initialRoute: AppRoutes.splash,
      getPages:     AppPages.pages,
    );
  }
}