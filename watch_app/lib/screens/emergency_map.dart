import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  final double lat;
  final double long;

  const MapPage({
    required this.lat,
    required this.long,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, long),
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('location_marker'),
            position: LatLng(lat, long),
          ),
        },
      ),
    );
  }
}
