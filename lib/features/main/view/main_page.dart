import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/common_nav_bar.dart';
import '../../home/views/home_page.dart';
import '../../home/views/shome_page.dart';
import '../../menu/views/menu_page.dart';
import '../../services/views/all_services_list.dart';
import '../../statistics/view/statistics_page.dart';
import '../controller/main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pages = controller.isServiceProvider
          ? const [
        StatisticsPage(),
        SHomePage(),
        MenuPage(),
      ]
          : const [
         AllServices(),
        HomePage(),
        MenuPage(),
      ];

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CommonBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeNavIndex,
          isServiceProvider: controller.isServiceProvider,
        ),
      );
    });
  }
}