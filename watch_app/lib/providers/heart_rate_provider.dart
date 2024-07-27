import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final heartRateProvider = StateNotifierProvider<HeartRateNotifier, HeartRateState>((ref) {
  return HeartRateNotifier();
});

class HeartRateState {
  final int heart;
  final String hrtstat;
  final String wastat;
  final Color statcol;

  HeartRateState({
    this.heart = 0,
    this.hrtstat = "loading...",
    this.wastat = "loading...",
    this.statcol = Colors.black,
  });
}

class HeartRateNotifier extends StateNotifier<HeartRateState> {
  final ip=dotenv.env["IP"];
  HeartRateNotifier() : super(HeartRateState()) {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadHeartStatus();
    });
  }

  Future<void> _loadHeartStatus() async {
    try {
      final response = await http.get(Uri.parse('http://$ip/heartbeat'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = HeartRateState(
          heart: data['heartbeat'],
          hrtstat: "${data['heartbeat']} BPM",
          wastat: "Active",
          statcol: const Color.fromARGB(255, 9, 186, 15),
        );
      } else {
        state = HeartRateState(
          wastat: "Inactive",
          hrtstat: "Unavailable",
          statcol: const Color.fromARGB(255, 183, 17, 5),
        );
      }
    } catch (e) {
      state = HeartRateState(
        wastat: "Inactive",
        hrtstat: "Unavailable",
        statcol: const Color.fromARGB(255, 183, 17, 5),
      );
      print(e);
    }
  }
}
