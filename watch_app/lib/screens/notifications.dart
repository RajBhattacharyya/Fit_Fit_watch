import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_app/providers/notif_provider.dart';
import 'package:watch_app/widgets/notif_card.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final notificationNotifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              notificationNotifier.fetchNotifications();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 175, 175, 175),
              Color.fromARGB(255, 223, 223, 223)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.7],
          ),
        ),
        child: notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Color.fromARGB(255, 150, 149, 149),
                      size: 100.0,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'No notification to display',
                      style: TextStyle(
                        color: Color.fromARGB(255, 119, 119, 119),
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    name: notification['name'] ?? 'Unknown',
                    message: notification['message'] ?? 'No message',
                    lat: notification['lat'] ?? 0.0,
                    long: notification['long'] ?? 0.0,
                  );
                },
              ),
      ),
    );
  }
}
