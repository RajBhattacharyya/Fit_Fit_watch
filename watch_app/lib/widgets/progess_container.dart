import 'package:flutter/material.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

class ProgessContainer extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String goal;
  final String reward;
  final String progress;
  final double progressValue;

  const ProgessContainer({
    super.key,
    required this.icon,
    this.iconColor,
    required this.goal,
    required this.reward,
    required this.progress,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor ??
                  const Color.fromARGB(
                      255, 4, 181, 21), // Default color if iconColor is null
            ),
            const SizedBox(
              width: 8,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          goal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          reward,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  ProgressBar(
                    value: progressValue,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Colors.purple,
                      ],
                    ),
                    backgroundColor: Colors.grey.withOpacity(0.4),
                    width: 280,
                    height: 13,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          progress,
                          style: TextStyle(
                            color: progress == 'Completed'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
