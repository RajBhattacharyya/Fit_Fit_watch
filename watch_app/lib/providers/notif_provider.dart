import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<Map<String, dynamic>>>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Timer? _timer;

  NotificationNotifier() : super([]) {
    fetchNotifications();
    _startPeriodicFetch();
  }

  Future<void> fetchNotifications() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifs')
          .get();

      final List<Map<String, dynamic>> newNotifications = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': doc.id, 
          'message': data['symp'] ?? 'No message',
          'lat': double.parse(data['lat']),
          'long': double.parse(data['long']),
        };
      }).toList();

      state = newNotifications;
      print('Notifications fetched successfully: $newNotifications');
    } catch (error) {
      print('Error fetching notifications: $error');
    }
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
