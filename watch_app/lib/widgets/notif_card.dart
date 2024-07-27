import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String name;
  final String message;
  final double lat;
  final double long;

  const NotificationCard({
    required this.name,
    required this.message,
    required this.lat,
    required this.long,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(message),
        trailing: Text('Lat: $lat, Long: $long'),
      ),
    );
  }
}
