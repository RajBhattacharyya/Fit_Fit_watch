import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:watch_app/widgets/map_key_table.dart';

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NotifScreenState();
  }
}

class _NotifScreenState extends State<NotifScreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];
  Polyline? _polyline;
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API']!;
  late final Location _location;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _getLocation();
    _getIncidents();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _location.onLocationChanged.listen((LocationData newLocation) {
      _handleLocationUpdate(newLocation);
    });

    if (currentLocation == null) {
      currentLocation = await _location.getLocation();
      _handleLocationUpdate(currentLocation!);
    }
  }

  void _handleLocationUpdate(LocationData newLocation) {
    if (mounted) {
      setState(() {
        currentLocation = newLocation;

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            ),
          );
        }

        _getNearbyPlaces(); // Optional if you need to refresh nearby places
      });
    }
  }

  Future<void> _getIncidents() async {
    FirebaseFirestore.instance
        .collection('incidents')
        .get()
        .then((querySnapshot) async {
      final newMarkers = <Marker>{};

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        var type = data['type'];
        var location = data['location'];
        BitmapDescriptor customIcon = await _getMarkerIcon(type);
        var marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: '${_getIcon(type)} $type',
          ),
          icon: customIcon,
        );
        newMarkers.add(marker);
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    });
  }

  Future<void> _getNearbyPlaces() async {
    if (currentLocation != null) {
      const String baseUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      final String location =
          '${currentLocation!.latitude},${currentLocation!.longitude}';
      const int radius = 10000; // Search within a 10 km radius

      final String hospitalsUrl =
          '$baseUrl?location=$location&radius=$radius&type=hospital&key=$_apiKey';
      final String policeUrl =
          '$baseUrl?location=$location&radius=$radius&type=police&key=$_apiKey';
      final String fireStationsUrl =
          '$baseUrl?location=$location&radius=$radius&type=fire_station&key=$_apiKey';

      await _fetchAndDisplayPlaces(hospitalsUrl, 'hospital');
      await _fetchAndDisplayPlaces(policeUrl, 'police');
      await _fetchAndDisplayPlaces(fireStationsUrl, 'fire_station');
    }
  }

  Future<BitmapDescriptor> _getMarkerIcon(String type) async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/icons/$type.png',
    );
  }

  Future<void> _fetchAndDisplayPlaces(String url, String type) async {
    print('Fetching places from: $url'); // Debugging line

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      if (results.isEmpty) {
        print('No nearby $type found'); // Debugging line
      }

      final newMarkers = <Marker>{};
      for (var place in results) {
        final placeId = place['place_id'];
        final name = place['name'];
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        BitmapDescriptor customIcon = await _getMarkerIcon(type);

        final marker = Marker(
            markerId: MarkerId(placeId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: '${_getIcon(type)} $name',
            ),
            icon: customIcon,
            onTap: () => _getDirections(lat, lng));

        newMarkers.add(marker);
      }

      if (mounted) {
        setState(() {
          _markers.addAll(newMarkers);
        });
      }
    } else {
      print('Failed to load nearby places: ${response.statusCode}'); // Debugging line
    }
  }

  String _getIcon(String type) {
    switch (type) {
      case 'hospital':
        return '🏥';
      case 'police':
        return '👮';
      case 'fire_station':
        return '🚒';
      case 'accident':
        return '⚠️';
      case 'crime':
        return '🚨';
      default:
        return '📍';
    }
  }

  Future<void> _getDirections(double destLat, double destLng) async {
    if (currentLocation != null) {
      const String baseUrl =
          'https://maps.googleapis.com/maps/api/directions/json';
      final String origin =
          '${currentLocation!.latitude},${currentLocation!.longitude}';
      final String destination = '$destLat,$destLng';

      final String url =
          '$baseUrl?origin=$origin&destination=$destination&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

        _polylineCoordinates.clear();
        for (var step in steps) {
          final startLat = step['start_location']['lat'];
          final startLng = step['start_location']['lng'];
          final endLat = step['end_location']['lat'];
          final endLng = step['end_location']['lng'];

          _polylineCoordinates.add(LatLng(startLat, startLng));
          _polylineCoordinates.add(LatLng(endLat, endLng));
        }

        if (mounted) {
          setState(() {
            _polyline = Polyline(
              polylineId: const PolylineId('route'),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            );
          });
        }
      } else {
        print('Failed to load directions: ${response.statusCode}'); // Debugging line
      }
    }
  }

  void _reportIncident() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Incident"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text("Accident"),
                onTap: () {
                  _saveIncident("accident");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Crime"),
                onTap: () {
                  _saveIncident("crime");
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveIncident(String type) async {
    if (currentLocation != null) {
      await FirebaseFirestore.instance.collection('incidents').add({
        'type': type,
        'location':
            GeoPoint(currentLocation!.latitude!, currentLocation!.longitude!),
        'timestamp': Timestamp.now(),
      });

      // Fetch incidents again to refresh the markers
      _getIncidents();
    } else {
      // Handle the case when current location is null
      print("Current location is null. Unable to save incident.");
    }
  }

  void _zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: Stack(
        children: <Widget>[
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  markers: _markers,
                  polylines:
                      _polyline != null ? <Polyline>{_polyline!} : <Polyline>{},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
          const Positioned(
            top: 10,
            right: 10,
            child: Legend(), // Display the legend in the top right corner
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 2),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reportIncident,
        icon: const Icon(Icons.report),
        label: const Text("Report"),
      ),
    );
  }
}
