import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLegendItem('🏥', Colors.cyan, 'Hospitals'),
          _buildLegendItem('👮', Colors.blue, 'Police Stations'),
          _buildLegendItem('🚒', Colors.orange, 'Fire Stations'),
          _buildLegendItem('⚠️', Colors.blue, 'Accidents'),
          _buildLegendItem('🚨', Colors.red, 'Crimes'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String icon, Color color, String text) {
    return Row(
      children: <Widget>[
        Text(icon),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }
}
