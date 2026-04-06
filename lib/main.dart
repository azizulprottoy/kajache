import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initServices();
  runApp(const KajAcheApp());
}

Future<void> _initServices() async {
  await Get.putAsync(() => LocalStorageService().init());
  await Get.putAsync(() => SecureStorageService().init());
}