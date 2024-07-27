import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Gridder extends StatefulWidget {
  const Gridder({
    super.key,
    required this.totalDistanceToday,
    required this.totalStepsToday,
    required this.totalCaloriesToday,
  });

  final double totalDistanceToday;
  final int totalStepsToday;
  final double totalCaloriesToday;

  @override
  State<Gridder> createState() {
    return _Gridder();
  }
}

class _Gridder extends State<Gridder> with SingleTickerProviderStateMixin {
  late final String? ip;
  int heart = 60;
  List<double> ecgData = List.generate(100, (_) => 0);
  late Timer _iconTimer;
  double _iconSize = 24.0;
  bool _iconSizeToggle = false;

  @override
  void initState() {
    super.initState();
    ip = dotenv.env["IP"];
    if (ip != null) {
      _fetchBeat();
      Timer.periodic(const Duration(milliseconds: 8), (timer) {
        _updateECG();
      });
      Timer.periodic(const Duration(seconds: 2), (timer) {
        _fetchBeat();
      });
    }
    _iconTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _iconSizeToggle = !_iconSizeToggle;
        _iconSize = _iconSizeToggle ? 30.0 : 24.0;
      });
    });
  }

  @override
  void dispose() {
    _iconTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchBeat() async {
    if (ip == null) return;
    try {
      final response = await http.get(Uri.parse('http://$ip/heartbeat'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          heart = data['heartbeat'];
        });
      } else {
        throw Exception('Failed to load heartbeat');
      }
    } catch (e) {
      print(e);
    }
  }

  void _updateECG() {
    setState(() {
      ecgData.removeAt(0);
      ecgData.add(_generateECGPoint());
    });
  }

  double _generateECGPoint() {
    final random = Random();
    double frequency =
        0.6 + (heart - 60) / 100; // Adjust frequency based on heart rate
    double amplitude =
        0.2 + (heart - 60) / 100; // Adjust amplitude based on heart rate
    double phase = random.nextDouble() * 2 * pi; // Random phase shift
    return sin(phase + random.nextDouble() * pi * 2 * frequency) * amplitude;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 18, left: 18, right: 18),
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 2,
            child: buildHealthCard(
              'Heart rate',
              heart.toString(),
              'bpm',
              Icons.favorite,
              const Color.fromARGB(216, 187, 222, 251),
              Colors.red,
              Colors.blue,
              showECG: true,
              iconSize: _iconSize,
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: buildHealthCard(
              'Steps',
              widget.totalStepsToday.toString(),
              'steps',
              Icons.run_circle_outlined,
              const Color.fromARGB(211, 255, 228, 191),
              const Color.fromARGB(255, 255, 153, 0),
              const Color.fromARGB(255, 255, 153, 1),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: buildHealthCard(
              'Calories',
              widget.totalCaloriesToday.toStringAsFixed(2),
              'Kcal',
              Icons.local_fire_department,
              const Color.fromARGB(213, 255, 236, 179),
              const Color.fromARGB(255, 245, 160, 3),
              const Color.fromARGB(255, 240, 147, 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHealthCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    Color borderColor, {
    bool showECG = false,
    double iconSize = 24.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 30, // Fixed width
                height: 30, // Fixed height
                alignment: Alignment.center,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: title == 'Heart rate' ? 8 : 0,
          ),
          if (showECG)
            Expanded(
              child: CustomPaint(
                painter: ECGPainter(ecgData),
                size: Size.infinite,
              ),
            ),
          SizedBox(
            height: title == 'Heart rate' ? 2 : 20,
          ),
          Center(
            child: Text(
              value,
              style: title == 'Heart rate'
                  ? const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    )
                  : const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
          if (unit.isNotEmpty)
            Center(
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ECGPainter extends CustomPainter {
  final List<double> ecgData;

  ECGPainter(this.ecgData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final stepX = width / (ecgData.length - 1);

    path.moveTo(0, height / 2);

    for (int i = 0; i < ecgData.length - 1; i++) {
      final x1 = stepX * i;
      final y1 = height / 2 - (ecgData[i] * height / 2);
      final x2 = stepX * (i + 1);
      final y2 = height / 2 - (ecgData[i + 1] * height / 2);

      final cx = (x1 + x2) / 2;
      final cy1 = y1;
      final cy2 = y2;

      path.cubicTo(cx, cy1, cx, cy2, x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
