import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Records {
  final bool isRecording;
  final int elapsedSeconds;
  final double distanceTravelled;
  final List<LatLng> routeCoordinates;
  final Timer? timer;
  final bool showSaveDiscardButtons;
  final DateTime currentDate; // New property to track current date
  final double totalDistanceToday; // New property for total distance
  final int totalTimeToday; // New property for total time

  Records({
    this.isRecording = false,
    this.elapsedSeconds = 0,
    this.distanceTravelled = 0.0,
    this.routeCoordinates = const [],
    this.timer,
    this.showSaveDiscardButtons = false,
    DateTime? currentDate,
    this.totalDistanceToday = 0.0,
    this.totalTimeToday = 0,
  }) : currentDate = currentDate ?? DateTime.now(); // Assign current date

  Records copyWith({
    bool? isRecording,
    int? elapsedSeconds,
    double? distanceTravelled,
    List<LatLng>? routeCoordinates,
    Timer? timer,
    bool? showSaveDiscardButtons,
    DateTime? currentDate,
    double? totalDistanceToday,
    int? totalTimeToday,
  }) {
    return Records(
      isRecording: isRecording ?? this.isRecording,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceTravelled: distanceTravelled ?? this.distanceTravelled,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      timer: timer ?? this.timer,
      showSaveDiscardButtons: showSaveDiscardButtons ?? this.showSaveDiscardButtons,
      currentDate: currentDate ?? this.currentDate,
      totalDistanceToday: totalDistanceToday ?? this.totalDistanceToday,
      totalTimeToday: totalTimeToday ?? this.totalTimeToday,
    );
  }
}
