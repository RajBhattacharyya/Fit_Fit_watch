import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:watch_app/backend/aipro2.dart';
import 'package:watch_app/data/rec.dart';
import 'package:watch_app/providers/heart_rate_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

const List<String> _videoIds = [
  'tcodrIK2P_I',
  'H5v3kku4y6Q',
  'nPt8bK2gbaU',
  'K18cpp_-gP8',
  'iLnmTe5Q2Qw',
  '_WoCV4c6XOE',
  'KmzdUe0RSJo',
  '6jZDSSZZxjQ',
  'p2lYr3vM_1w',
  '7QUtEmBT_-w',
  '34_PXCzGw1M'
];

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() {
    return _AiScreen();
  }
}

class _AiScreen extends ConsumerState<AiScreen> {
  String? name = '';
  dynamic predictionResult = 'Crunching your Data...';
  String res = 'Processing...';
  String prevpred = '';
  var dynamicIcon = const Icon(Icons.warning, color: Colors.red);
  late List<_ChartData> data;
  late List<ChartDatas> chartDatas;
  late TooltipBehavior _tooltip;
  late TooltipBehavior _tooltip2;

  @override
  void initState() {
    super.initState();
    _loadName();
    _fetchPrediction();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchPrediction();
    });
    data = [
      _ChartData('MON', 6000),
      _ChartData('TUE', 3500),
      _ChartData('WED', 5000),
      _ChartData('THUR', 6000),
      _ChartData('FRI', 2000),
      _ChartData('SAT', 1000),
      _ChartData('SUN', 8000),
    ];
    chartDatas = [
      ChartDatas('A', 60),
      ChartDatas('B', 80),
      ChartDatas('C', 90),
    ];
    _tooltip = TooltipBehavior(enable: true);
    _tooltip2 = TooltipBehavior(enable: true);
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
  }

  Future<void> _fetchPrediction() async {
    try {
      List prediction = await rain();
      setState(() {
        predictionResult =
            prediction.isNotEmpty ? prediction[0] : 'No prediction available';
        if (predictionResult == 0.0) {
          predictionResult = "HEALTH STATUS NORMAL";
        } else {
          predictionResult = "ABNORMAL HEALTH STATUS DETECTED";
        }
        List<String> selectedRecommendations =
            recommendations[predictionResult]!;

        if (predictionResult != prevpred) {
          res = selectedRecommendations[
              Random().nextInt(selectedRecommendations.length)];
          prevpred = predictionResult;
        }
      });
    } catch (e) {
      setState(() {
        predictionResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final heartRateState = ref.watch(heartRateProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 149, 234, 244), // Light Blue
              Color(0xFFF5F5F5), // Light Grey
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 55),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $name!',
                        style: GoogleFonts.montserrat(
                            fontSize: 29, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "Welcome to AI based realtime",
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "health checkup system.",
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12.0, left: 12, right: 12),
                    child: Image.asset(
                      "assets/ai/ai1.gif",
                      width: 102,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: const Color.fromARGB(225, 255, 255, 255),
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12, left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Health Status",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/emo/problem.gif",
                                  width: 120,
                                ),
                                const SizedBox(width: 40),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.monitor_heart),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Status: ",
                                          style:
                                              GoogleFonts.roboto(fontSize: 14),
                                        ),
                                        Text(
                                          heartRateState.hrtstat,
                                          style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: heartRateState.statcol,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.bloodtype),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Oxygen Saturation: 85%",
                                          style:
                                              GoogleFonts.roboto(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "Recommendations:",
                                  style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  res,
                                  style: GoogleFonts.roboto(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color.fromARGB(225, 255, 255, 255),
                      margin: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5, bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "YouTube Recommendations",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 180,
                                autoPlay: false,
                                viewportFraction: 0.8,
                                enlargeCenterPage: true,
                              ),
                              items: [
                                'WL8w8ynq2Xw',
                                'WL8w8ynq2Xw',
                                'WL8w8ynq2Xw',
                              ].map((videoId) {
                                YoutubePlayerController controller =
                                    YoutubePlayerController.fromVideoId(
                                  videoId: videoId,
                                  autoPlay: false,
                                  params: const YoutubePlayerParams(
                                    mute: false,
                                  ),
                                );
                                return Container(
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: YoutubePlayer(
                                      controller: controller,
                                      aspectRatio: 16/9,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: const Color.fromARGB(225, 255, 255, 255),
                      margin: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5, bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                "AI Analysis",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 160,
                              width: 160,
                              child: SfCircularChart(
                                  tooltipBehavior: _tooltip2,
                                  series: <CircularSeries>[
                                    RadialBarSeries<ChartDatas, String>(
                                      animationDuration: 5000,
                                      dataSource: chartDatas,
                                      xValueMapper: (ChartDatas data, _) =>
                                          data.person,
                                      yValueMapper: (ChartDatas data, _) =>
                                          data.status,
                                    )
                                  ]),
                            ),
                            SizedBox(
                              height: 200,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                primaryXAxis: const CategoryAxis(
                                  majorGridLines: MajorGridLines(width: 0),
                                  title: AxisTitle(
                                    text: 'Days', // Set your x-axis title here
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                primaryYAxis: const NumericAxis(
                                  title: AxisTitle(
                                    text: 'Steps', // Set your y-axis title here
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  minimum: 0,
                                  maximum: 10000,
                                  interval: 2000,
                                  majorGridLines: MajorGridLines(width: 0),
                                  minorGridLines: MinorGridLines(width: 0),
                                ),
                                tooltipBehavior: _tooltip,
                                series: <CartesianSeries<_ChartData, String>>[
                                  ColumnSeries<_ChartData, String>(
                                    dataSource: data,
                                    xValueMapper: (_ChartData data, _) =>
                                        data.x,
                                    yValueMapper: (_ChartData data, _) =>
                                        data.y,
                                    name: 'Steps',
                                    color: const Color.fromRGBO(8, 142, 255, 1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      topRight: Radius.circular(11),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartDatas {
  ChartDatas(this.person, this.status);
  final String person;
  final double status;
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
