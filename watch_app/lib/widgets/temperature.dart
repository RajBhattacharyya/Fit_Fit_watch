import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_app/providers/temperature_provider.dart';



class Temperature extends ConsumerWidget {
  const Temperature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<String> temperatureData = ref.watch(temperatureProvider);

    return Center(
    child: temperatureData.when(
    loading: () => const CircularProgressIndicator(color: Colors.white,),
    error: (error, stackTrace) => Text('Error: $error'),
    data: (temperature) => Text(
      temperature,
      style: const TextStyle(
        color:  Colors.white,
        fontSize: 20.0,
      ),
    ),
  ),
);
}
}