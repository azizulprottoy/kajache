import 'package:get/get.dart';

class RewardsController extends GetxController {
  final RxInt totalPoints = 320.obs;
  final RxList<RewardHistoryModel> rewardHistory = <RewardHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRewards();
  }

  void loadRewards() {
    rewardHistory.assignAll([
      RewardHistoryModel(
        title: 'Order Completed Bonus',
        date: '12 Mar 2026',
        points: 50,
      ),
      RewardHistoryModel(
        title: 'Referral Reward',
        date: '05 Mar 2026',
        points: 100,
      ),
      RewardHistoryModel(
        title: 'First Booking Reward',
        date: '28 Feb 2026',
        points: 70,
      ),
      RewardHistoryModel(
        title: 'Special Campaign Bonus',
        date: '20 Feb 2026',
        points: 100,
      ),
    ]);
  }
}

class RewardHistoryModel {
  final String title;
  final String date;
  final int points;

  RewardHistoryModel({
    required this.title,
    required this.date,
    required this.points,
  });
}