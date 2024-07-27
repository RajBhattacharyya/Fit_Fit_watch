import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecordDetailScreen extends StatelessWidget {
  final List<LatLng> routeCoordinates;
  final int duration;
  final double distance;

  const RecordDetailScreen({
    super.key,
    required this.routeCoordinates,
    required this.duration,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Details')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: routeCoordinates.first,
                zoom: 18,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('recordRoute'),
                  points: routeCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Time: ${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  'Distance: ${distance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
