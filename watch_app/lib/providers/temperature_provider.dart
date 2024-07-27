import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Provider to fetch temperature asynchronously

final temperatureProvider = FutureProvider<String>((ref) async {
  final temperature = await _fetchTemperature();
  return temperature;
});

// Function to fetch temperature based on current location
Future<String> _fetchTemperature() async {
  try {
    if (await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      String apiKey = 'e1896349d647ae5208c3f5bea5d107c9'; // Replace with your OpenWeatherMap API key
      String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return '${data['main']['temp']}°C'; // Return temperature as a formatted string
      } else {
        return 'Error fetching temperature';
      }
    } else {
      return 'Location permission denied';
    }
  } catch (e) {
    return 'Error fetching temperature';
  }
}

// Function to handle location permission
Future<bool> _handleLocationPermission() async {
  var status = await Permission.locationWhenInUse.status;
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  } else {
    return false;
  }
}
