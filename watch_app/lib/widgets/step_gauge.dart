import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class StepGauge extends StatefulWidget {
  final int steps;

  const StepGauge({super.key, required this.steps});

  @override
  State<StepGauge> createState() {
    return _StepGaugeState();
  }
}

class _StepGaugeState extends State<StepGauge> {
  late int _currentSteps;

  @override
  void initState() {
    super.initState();
    _currentSteps = widget.steps;
  }

  @override
  void didUpdateWidget(covariant StepGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps != _currentSteps) {
      setState(() {
        _currentSteps = widget.steps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      heightFactor: 0.75,
      child: Stack(
        children: [
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                radiusFactor: 0.5,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.1,
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                labelFormat: '',
                minorTickStyle: const MinorTickStyle(length: 0),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: ((_currentSteps.toDouble()-10000) / 2499) * 100,
                    width: 0.1,
                    sizeUnit: GaugeSizeUnit.factor,
                    gradient: const SweepGradient(
                      colors: <Color>[
                        Color.fromARGB(255, 230, 145, 172),
                        Color.fromARGB(255, 200, 133, 223)
                      ],
                      stops: <double>[0.25, 0.75],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_currentSteps',
                  style: const TextStyle(color: Colors.white),
                ),
                const Text(
                  'Steps',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
