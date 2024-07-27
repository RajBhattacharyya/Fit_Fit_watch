import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<Map<String, dynamic>>>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Timer? _timer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationNotifier()
      : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(),
        super([]) {
    _initializeNotifications();
    fetchNotifications();
    _startPeriodicFetch();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    androidImplementation?.requestNotificationsPermission();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.104:5000/notifs'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Map<String, dynamic>> newNotifications = List<Map<String, dynamic>>.from(responseData);

        if (newNotifications.isNotEmpty && newNotifications.length > state.length) {
          final newNotification = newNotifications.last;
          _showNotification('Notification', newNotification['message']);
        }

        state = newNotifications;
        print('Notifications fetched successfully: $responseData');
      } else {
        print('Failed to load notifications: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
