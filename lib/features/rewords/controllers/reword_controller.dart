import 'package:get/get.dart';

import '../../profile/repository/profile_repository.dart';
import '../models/reword_model.dart';
import '../repository/reword_repository.dart';

class RewardsController extends GetxController {
  final RewordRepository _rewordRepository;
  final ProfileRepository _profileRepository;

  RewardsController({
    RewordRepository? rewordRepository,
    ProfileRepository? profileRepository,
  })  : _rewordRepository = rewordRepository ?? RewordRepository(),
        _profileRepository = profileRepository ?? ProfileRepository();

  final RxInt totalPoints = 0.obs;
  final RxList<RewordModel> rewards = <RewordModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRewards();
  }

  Future<void> loadRewards() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final rewardsFuture = _rewordRepository.getRewards();
      final profileFuture = _profileRepository.getMyProfile();

      final fetchedRewards = await rewardsFuture;
      final profile = await profileFuture;

      fetchedRewards.sort((a, b) => a.minpoint.compareTo(b.minpoint));
      rewards.assignAll(fetchedRewards);
      totalPoints.value = profile.points;
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  bool isUnlocked(RewordModel reward) => totalPoints.value >= reward.minpoint;

  int pointsRemaining(RewordModel reward) {
    final remaining = reward.minpoint - totalPoints.value;
    return remaining < 0 ? 0 : remaining;
  }
}
