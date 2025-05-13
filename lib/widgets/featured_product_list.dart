import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeaturedProductList extends StatelessWidget {
  const FeaturedProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('products').limit(5).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found."));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductTile(
                product['name'],
                product['imageUrl'], // Example: "assets/products/cat1.png"
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductTile(String name, String imagePath) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Image.asset(imagePath, height: 80),
          SizedBox(height: 8),
          Text(name, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
