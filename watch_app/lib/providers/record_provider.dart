import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:watch_app/helpers/database_helper.dart';
import 'package:watch_app/model/records.dart';
import 'package:watch_app/web3/balance_notifier.dart';
import 'package:watch_app/web3/eth_service.dart';

final recordProvider = StateNotifierProvider<RecordingStateNotifier, Records>((ref) {
  return RecordingStateNotifier(ref);
});

class RecordingStateNotifier extends StateNotifier<Records> {
  final Ref ref;

  RecordingStateNotifier(this.ref) : super(Records());

  void startRecording() {
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAndResetDailyTotals();
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
        totalTimeToday: state.totalTimeToday + 1,
      );
    });
    state = state.copyWith(isRecording: true, timer: timer);
  }

  void stopRecording() {
    state.timer?.cancel();
    state = state.copyWith(isRecording: false, showSaveDiscardButtons: true);
  }

  void saveRecord() async {
    await _saveRecord();
    state = Records();
  }

  void discardRecord() {
    state = Records();
  }

  void updateRoute(LatLng position) {
    final lastPosition =
        state.routeCoordinates.isEmpty ? null : state.routeCoordinates.last;
    final newDistance =
        lastPosition != null ? _calculateDistance(lastPosition, position) : 0.0;
    final newRouteCoordinates = List<LatLng>.from(state.routeCoordinates)
      ..add(position);
    _checkAndResetDailyTotals();
    state = state.copyWith(
      distanceTravelled: state.distanceTravelled + newDistance,
      routeCoordinates: newRouteCoordinates,
      totalDistanceToday: state.totalDistanceToday + newDistance,
    );
    _handleDistanceUpdate(state.totalDistanceToday);
  }

  Future<void> _saveRecord() async {
    String routeJson = jsonEncode(state.routeCoordinates
        .map((e) => {'lat': e.latitude, 'lng': e.longitude})
        .toList());
    Map<String, dynamic> record = {
      'date': DateTime.now().toIso8601String(),
      'duration': state.elapsedSeconds,
      'distance': state.distanceTravelled,
      'route': routeJson,
    };
    print(record);
    await DatabaseHelper().insertRecord(record);
  }

  void _checkAndResetDailyTotals() {
    final now = DateTime.now();
    if (now.day != state.currentDate.day ||
        now.month != state.currentDate.month ||
        now.year != state.currentDate.year) {
      state = state.copyWith(
        currentDate: now,
        totalDistanceToday: 0.0,
        totalTimeToday: 0,
      );
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371e3; // metres
    final double phi1 = start.latitude * (3.14159 / 180);
    final double phi2 = end.latitude * (3.14159 / 180);
    final double deltaPhi = (end.latitude - start.latitude) * (3.14159 / 180);
    final double deltaLambda =
        (end.longitude - start.longitude) * (3.14159 / 180);

    final double a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
        (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c / 1000; // returns the distance in kilometers
  }

  void _handleDistanceUpdate(double distance) async {
    if (distance > 0) {
      final ethService = ref.read(ethServiceProvider);
      final balanceNotifier = ref.read(balanceProvider.notifier);
      // Convert distance to Wei (assuming 1 km = 1 Ether for simplicity)
      final amount = BigInt.from(distance * 1e18);
      await balanceNotifier.sendEther(amount);
    }
  }
}


