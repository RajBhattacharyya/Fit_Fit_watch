import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List> rain() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String age = prefs.getString('age') ?? '';
  String disease = prefs.getString('disease') ?? '';
  String gender = prefs.getString('gender') ?? '';
  gender = (gender == 'male') ? "1" : "0";
    Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;
  String? name = prefs.getString('name') ?? '';

  final ip = dotenv.env["IP"];
  final directory = await getApplicationDocumentsDirectory();
  final pathToFile = '${directory.path}/classifier.json';

  final file = File(pathToFile);
  final encodedModel = await file.readAsString();

  final model = LogisticRegressor.fromJson(encodedModel);
  double temp = 39;
  int hrt = 0;

  // Fetch heartbeat and temperature
  Future<void> fetchSteps() async {
    try {
      final response = await http.get(Uri.parse('http://$ip/heartbeat'));
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        hrt = data['heartbeat'];
      } else {
        throw Exception('Failed to load steps');
      }
    } catch (e) {
      print(e);
    }

    String apiKey = 'e1896349d647ae5208c3f5bea5d107c9';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      temp = data['main']['temp'];
    } else {
      temp = 0;
    }
  }

  // Ensure the asynchronous function completes
  await fetchSteps();

  // Use the updated hrt and temp values in the prediction
  final prediction = model.predict(DataFrame([
    ["Age", "Gender", "Heart Rate", "Outside Temperature"],
    [age, gender, hrt, temp],
  ]));

  List res = [];
  print({hrt, gender});
  res.add(prediction.rows.first.first);
  print(prediction.rows.first.first);

  // Example of sending data if condition is met
  if (res[0] != 0.0) {
    String sendUrl = 'http://192.168.0.104:5000/send/$name/$latitude/$longitude/emergency';
    print('$latitude');
    http.get(Uri.parse(sendUrl));
  }

  return res;
}
