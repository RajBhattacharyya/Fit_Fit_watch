import 'package:flutter/material.dart';
import 'package:watch_app/screens/emergency_map.dart';

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
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              lat: lat,
              long: long,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                message,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Location: ($lat, $long)',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
