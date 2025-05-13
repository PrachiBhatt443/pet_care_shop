import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double price;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12)),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text('\₹${price.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800])),
          ),
        ],
      ),
    );
  }
}
