import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_app/providers/record_provider.dart';
import 'package:watch_app/screens/record_list.dart';
import 'package:watch_app/screens/tryscreen.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RecordScreenState();
  }
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  GoogleMapController? _controller;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (ref.read(recordProvider).isRecording) {
        ref.read(recordProvider.notifier).updateRoute(
            LatLng(currentLocation.latitude!, currentLocation.longitude!));
      }
    });
  }

  @override
Widget build(BuildContext context) {
  final recordingState = ref.watch(recordProvider);
  final recordingNotifier = ref.read(recordProvider.notifier);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Record'),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordListScreen()),
            );
          },
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.8,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 14,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _location.getLocation().then((location) {
                    _controller!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(location.latitude!, location.longitude!),
                          zoom: 15,
                        ),
                      ),
                    );
                  });
                },
                myLocationEnabled: true,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: recordingState.routeCoordinates,
                    color: Colors.blue,
                    width: 5,
                  ),
                },
              ),
            ),
            Container(
              height: constraints.maxHeight * 0.2,
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Time: ${recordingState.elapsedSeconds ~/ 60}:${(recordingState.elapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Distance: ${recordingState.distanceTravelled.toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  if (recordingState.showSaveDiscardButtons) 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: recordingNotifier.saveRecord,
                          child: const Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: recordingNotifier.discardRecord,
                          child: const Text('Discard'),
                        ),
                      ],
                    )
                  else 
                    ElevatedButton(
                      onPressed: recordingState.isRecording
                          ? recordingNotifier.stopRecording
                          : recordingNotifier.startRecording,
                      child: Text(recordingState.isRecording ? 'Stop' : 'Start'),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}


  @override
  void dispose() {
    _controller?.dispose();
    ref.read(recordProvider.notifier).stopRecording();
    super.dispose();
  }
}
