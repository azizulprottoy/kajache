import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initServices();
  runApp(const KajAcheApp());
}

Future<void> _initServices() async {
  await Get.putAsync(() => LocalStorageService().init());
  await Get.putAsync(() => SecureStorageService().init());
  await Get.putAsync(() => PushNotificationService().init());
}