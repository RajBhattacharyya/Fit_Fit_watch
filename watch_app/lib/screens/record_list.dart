import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:watch_app/helpers/database_helper.dart';
import 'package:watch_app/screens/record_detail.dart';



final recordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await DatabaseHelper().getRecords();
});

class RecordListScreen extends ConsumerStatefulWidget {
  const RecordListScreen({super.key});

  @override
  ConsumerState<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends ConsumerState<RecordListScreen> {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _filteredRecords = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(recordsProvider); // Refresh the provider
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _filterRecords(ref.read(recordsProvider).value ?? []);
    }
  }

  void _filterRecords(List<Map<String, dynamic>> records) {
    if (_selectedDate != null) {
      _filteredRecords = records
          .where((record) =>
              DateFormat('yyyy-MM-dd').format(DateTime.parse(record['date'])) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate!))
          .toList();
    } else {
      _filteredRecords = records;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsyncValue = ref.watch(recordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recorded Routes')),
      body: recordsAsyncValue.when(
        data: (records) {
          if (_selectedDate != null) {
            _filterRecords(records.reversed.toList());
          } else {
            _filteredRecords = records.reversed.toList();
          }

          if (_filteredRecords.isEmpty) {
            return const Center(child: Text('No records found'));
          }

          // Calculate total distance and total time for today
          double totalDistanceToday = _filteredRecords
              .where((record) =>
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(record['date'])) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now()))
              .map<double>((record) => record['distance'])
              .fold<double>(0, (prev, distance) => prev + distance);
          int totalTimeToday = _filteredRecords
              .where((record) =>
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(record['date'])) ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now()))
              .map<int>((record) => record['duration'])
              .fold<int>(0, (prev, duration) => prev + duration);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total Distance Today: ${totalDistanceToday.toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Time Today: ${totalTimeToday ~/ 60}:${(totalTimeToday % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Select a date'
                                : 'Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                              _filterRecords(records);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = _filteredRecords[index];
                    final routeCoordinates = (jsonDecode(record['route']) as List)
                        .map((point) => LatLng(point['lat'], point['lng']))
                        .toList();
                    final duration = record['duration'];
                    final distance = record['distance'];
                    final date = DateTime.parse(record['date']); // Parse the date
                    final formattedDate = DateFormat('yyyy-MM-dd').format(date); // Format the date

                    return ListTile(
                      title: Text('Record ${record['id']}'),
                      subtitle: Text(
                          'Date: $formattedDate\nDuration: ${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}, Distance: ${distance.toStringAsFixed(2)} km'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecordDetailScreen(
                            routeCoordinates: routeCoordinates,
                            duration: duration,
                            distance: distance,
                          ),
                        ));
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Error loading records')),
      ),
    );
  }
}
