import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:watch_app/helpers/database_helper.dart';
import 'package:watch_app/widgets/col_data.dart';
import 'package:watch_app/widgets/gridder.dart';

final recordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await DatabaseHelper().getRecords();
});

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  String? gender = '';
  String? weight = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(recordsProvider); // Refresh the provider
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gender = prefs.getString('gender') ?? '';
      weight = prefs.getString('weight') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsyncValue = ref.watch(recordsProvider);

    return recordsAsyncValue.when(
      data: (records) {
        double totalDistanceToday = 0;
        int totalStepsToday = 0;
        double totalCaloriesToday = 0;

        if (records.isNotEmpty) {
          totalDistanceToday = records
              .where((record) =>
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(record['date'])) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now()))
              .map<double>((record) => record['distance'])
              .fold<double>(0, (prev, distance) => prev + distance);

          int totalTimeToday = records
              .where((record) =>
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(record['date'])) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now()))
              .map<int>((record) => record['duration'])
              .fold<int>(0, (prev, duration) => prev + duration);

          if (gender == "Male") {
            totalStepsToday = (totalDistanceToday * 1316).round();
          } else {
            totalStepsToday = (totalDistanceToday * 1493).round();
          }

          if (totalTimeToday > 0) {
            double avgSpeed = totalDistanceToday / (totalTimeToday / 3600);
            double met;
            if (avgSpeed == 0) {
              met = 0;
            } else if (avgSpeed < 3.2) {
              met = 2.8;
            } else if (avgSpeed < 4.8) {
              met = 3.3;
            } else if (avgSpeed < 6.4) {
              met = 4.3;
            } else {
              met = 5.0;
            }
            print({met, weight, totalTimeToday / 3600});
            totalCaloriesToday =
                met * num.parse(weight!) * (totalTimeToday / 3600);
          }
        }

        return Scaffold(
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(114, 87, 233, 1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ColData(
                  totalDistanceToday: totalDistanceToday,
                  totalStepsToday: totalStepsToday,
                  totalCaloriesToday: totalCaloriesToday,
                ),
              ),
              const SizedBox(height: 15.0),
              Expanded(
                child: Gridder(
                  totalDistanceToday: totalDistanceToday,
                  totalStepsToday: totalStepsToday,
                  totalCaloriesToday: totalCaloriesToday,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
