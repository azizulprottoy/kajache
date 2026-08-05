import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../auth/controllers/login_controller.dart';
import '../../auth/controllers/register_controller.dart';

class MainController extends GetxController {
  final _localStorage = Get.find<LocalStorageService>();

  final RxInt currentIndex = 1.obs;
  final Rx<UserType> userType = UserType.buyer.obs;

  bool get isBuyer => userType.value == UserType.buyer;
  bool get isServiceProvider => userType.value == UserType.serviceProvider;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is UserType) {
      userType.value = arg;
      _localStorage.write('user_type', arg.name);
      return;
    }

    final storedType = _localStorage.read<String>('user_type');
    if (storedType == UserType.serviceProvider.name) {
      userType.value = UserType.serviceProvider;
    } else {
      userType.value = UserType.buyer;
    }

    _cacheUserAvatar();
  }

  Future<void> _cacheUserAvatar() async {
    if (_localStorage.read<String>('user_avatar') != null) return;
    try {
      final res = await ApiClient.instance.get('/profile/me');
      final data = res.data is Map ? res.data['data'] : null;
      if (data == null) return;
      final detail = data['profileDetail'] is Map ? data['profileDetail'] : null;
      final avatar = detail?['avatar']?.toString() ?? '';
      if (avatar.isNotEmpty) {
        _localStorage.write('user_avatar', avatar);
      }
    } catch (_) {}
  }

  void changeNavIndex(int index) {
    currentIndex.value = index;
  }
}