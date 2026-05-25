import 'package:get/get.dart';

class TermsConditionController extends GetxController {
  final RxString content = '''
By using this platform, you agree to the following terms:

1. Provide accurate service information.
2. Complete booked jobs responsibly and professionally.
3. Do not misuse customer information.
4. Follow platform rules and service policies.
5. Repeated violations may result in account restrictions.
'''.obs;
}