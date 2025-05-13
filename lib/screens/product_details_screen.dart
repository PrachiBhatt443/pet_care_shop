import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_app_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 0;
  String? purchaseId;

  // Theme colors
  final orangeTheme = const Color(0xFFEF6C00); // Burnt orange
  final creamTheme = const Color(0xFFFFFBF2); // Light orange
  final textBrown = const Color(0xFF6D4C41);  // Muted brown


  @override
  void initState() {
    super.initState();
    _loadCartQuantity();
  }

  Future<void> _loadCartQuantity() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

    final snapshot = await FirebaseFirestore.instance
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: widget.product['id'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      setState(() {
        quantity = doc['quantity'];
        purchaseId = doc.id;
      });
    }
  }

  Future<void> _addToCart() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

    final docRef = await FirebaseFirestore.instance.collection('purchases').add({
      'userId': userId,
      'productId': widget.product['id'],
      'quantity': 1,
      'totalPrice': widget.product['price'],
      'status': 'Pending',
      'purchasedAt': Timestamp.now(),
    });

    setState(() {
      quantity = 1;
      purchaseId = docRef.id;
    });

    Provider.of<CartProvider>(context, listen: false)
        .addItem(widget.product['id']);
  }

  Future<void> _updateQuantity(int newQty) async {
    if (purchaseId == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (newQty == 0) {
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(purchaseId)
          .delete();
      setState(() {
        quantity = 0;
        purchaseId = null;
      });
      cartProvider.removeItem(widget.product['id']);
    } else {
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(purchaseId)
          .update({
        'quantity': newQty,
        'totalPrice': widget.product['price'] * newQty,
      });
      setState(() {
        quantity = newQty;
      });
      cartProvider.updateItem(widget.product['id'], newQty);
    }
  }


  void _buyNow() async {
    // First add to cart if not already in cart
    if (quantity == 0) {
      await _addToCart();
    }

    // Navigate to checkout screen
    Navigator.of(context).pushNamed('/checkout');
  }

  Widget _buildQuantityControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _updateQuantity(quantity - 1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$quantity",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => _updateQuantity(quantity + 1),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
            icon: const Icon(Icons.shopping_cart, color: Color(0xFFEF6C00)),
            label: const Text(
              "View Cart",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF6C00),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEF6C00)),
              backgroundColor: Color(0xFFFFF3E0), // light orange shade
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: creamTheme,
      appBar: CustomAppBar(
        title: product['name'],
        // cartItemCount: quantity,
        onCartPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full width image with shadow
            Container(
              width: screenWidth,
              height: 280,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                product['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textBrown,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price and rating in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${product['price']}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: orangeTheme,
                        ),
                      ),

                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product['rating']?.toDouble() ?? 4.0,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "(${product['rating']?.toDouble() ?? 4.0})",
                            style: TextStyle(
                              color: textBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: textBrown.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Quantity controls or Add to Cart/Buy Now buttons
                  quantity > 0
                      ? _buildQuantityControls()
                      : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          label: const Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEF6C00), // Burnt orange
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _buyNow,
                          icon: const Icon(Icons.payment, color: Colors.white),
                          label: const Text(
                            "Buy Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6D4C41), // Muted brown
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}