import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:watch_app/model/store_items.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Container(
          height: 380,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              item.imageUrl,
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        Column(
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current Price: ',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  FontAwesome5Solid.coins,
                  color: Color.fromARGB(255, 231, 175, 7),
                  size: 16,
                ),
                Text(
                  item.currentPrice,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Text(
              'Original Price: ${item.originalPrice}',
              style: TextStyle(
                fontSize: 16.0,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
