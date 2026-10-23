import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/sbooking/booking_details_arguments.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/local_storage_service.dart';

/// Push notifications (Firebase Cloud Messaging).
///
/// - [onSignedIn] after login / on app start when already logged in: asks
///   permission, sends this device's token to the backend, opens the
///   notification that launched the app (if any).
/// - [onSignedOut] before the session is cleared: unregisters the device so
///   the next user of this phone doesn't get the previous user's pushes.
///
/// The backend puts `data.type` (+ ids) on every push; [_openFromData] maps
/// that to a screen.
class PushNotificationService extends GetxService {
  static PushNotificationService get to => Get.find();

  // Must match the channelId the backend sends (src/service/push.service.js).
  static const _channel = AndroidNotificationChannel(
    'kajache_default',
    'Notifications',
    description: 'Bookings, bids, messages and updates',
    importance: Importance.high,
  );

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  bool _listening = false;

  Future<PushNotificationService> init() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested through FirebaseMessaging in onSignedIn.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _openFromData(Map<String, dynamic>.from(jsonDecode(payload)));
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS shows foreground pushes itself; Android needs a local notification.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    return this;
  }

  /// Call once the user is logged in and the main screen is open.
  Future<void> onSignedIn() async {
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      _listen();
      // The ID arrives on onRegistered (handled in _listen).
      await _messaging.register();

      // App was launched by tapping a notification while it was closed.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _openFromData(initial.data);
    } catch (e) {
      debugPrint('Push setup failed: $e');
    }
  }

  /// Call before the auth token is cleared. [unregister] is false when the
  /// session already expired (the backend would reject the request).
  Future<void> onSignedOut({bool unregister = true}) async {
    try {
      final token = Get.find<LocalStorageService>().fcmToken;
      if (unregister && token != null) {
        await ApiClient.instance.delete(
          ApiEndpoints.deviceToken,
          data: {'token': token},
        );
      }
    } catch (e) {
      debugPrint('Push unregister failed: $e');
    }
    // A fresh ID is issued on next login; the old one stops working, so the
    // backend drops it even if the request above failed.
    try {
      await _messaging.unregister();
    } catch (_) {}
  }

  void _listen() {
    if (_listening) return;
    _listening = true;

    // Fires after register() and whenever Firebase rotates this device's ID.
    _messaging.onRegistered.listen(_registerToken);
    FirebaseMessaging.onMessage.listen(_showForeground);
    // App was in the background and the user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _openFromData(m.data));
  }

  Future<void> _registerToken(String token) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.deviceToken,
        data: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
      );
      Get.find<LocalStorageService>().setFcmToken(token);
    } catch (e) {
      debugPrint('Push token register failed: $e');
    }
  }

  void _showForeground(RemoteMessage message) {
    if (!Platform.isAndroid) return;
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _openFromData(Map<String, dynamic> data) {
    final isProvider =
        Get.find<LocalStorageService>().read<String>('user_type') ==
            'serviceProvider';
    String? id(String key) {
      final v = data[key]?.toString();
      return (v == null || v.isEmpty) ? null : v;
    }

    switch (data['type']) {
      case 'booking':
        final bookingId = id('bookingId');
        if (bookingId == null) return;
        if (isProvider) {
          Get.toNamed(AppRoutes.bookingDetails,
              arguments: BookingDetailsArgument(bookingId: bookingId));
        } else {
          Get.toNamed(AppRoutes.myBookingDetails, arguments: bookingId);
        }
      case 'bid_chat':
        final bidId = id('bidId');
        if (bidId != null) Get.toNamed(AppRoutes.chatPage, arguments: {'bidId': bidId});
      case 'instant_service':
        final serviceId = id('instantServiceId');
        if (isProvider) {
          // Opens that job's sheet (selected / paid / completed / cancelled state)
          Get.toNamed(AppRoutes.availableInstantServices,
              arguments: serviceId == null ? null : {'id': serviceId});
        } else if (serviceId != null) {
          Get.toNamed(AppRoutes.myInstantServiceDetails, arguments: serviceId);
        }
      case 'recruitment':
        final requestId = id('recruitmentRequestId');
        if (isProvider) {
          // Hired / not selected / ended / cancelled: the technician's applications
          Get.toNamed(AppRoutes.myRecruitmentApplications);
        } else if (requestId != null) {
          Get.toNamed(AppRoutes.myRecruitmentRequestDetails, arguments: requestId);
        }
      case 'support_chat':
        Get.toNamed(AppRoutes.supportChatPage);
    }
  }
}
