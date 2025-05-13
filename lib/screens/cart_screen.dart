import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart'; // Import the checkout screen

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];
  double cartTotal = 0.0;

  // Theme colors
  final orangeTheme = const Color(0xFFFFA726);
  final creamTheme = const Color(0xFFFFF8E1);
  final lightOrange = const Color(0xFFFFE0B2);
  final textBrown = const Color(0xFF8D6E63);
  final buttonOrange = const Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";
      print('Current user ID: $userId'); // Debug log to verify user ID

      // Get all purchases in pending status (cart items)
      final purchasesSnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .where('status', isEqualTo: 'Pending')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${purchasesSnapshot.docs.length} purchases'); // Debug log to check query results

      if (purchasesSnapshot.docs.isEmpty) {
        setState(() {
          cartItems = [];
          cartTotal = 0.0;
          isLoading = false;
        });
        return;
      }

      // Process cart items - handle both string and number productIds
      final items = await Future.wait(purchasesSnapshot.docs.map((purchaseDoc) async {
        final purchaseData = purchaseDoc.data();
        print('Processing purchase: $purchaseData'); // Debug log

        // Handle productId whether it's a number or string
        final productId = purchaseData['productId'];
        String productIdString = productId.toString();

        // Get the product data
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productIdString)
            .get();

        Map<String, dynamic> productData = {};
        if (productDoc.exists) {
          productData = productDoc.data() ?? {};
        } else {
          print('Product not found for ID: $productIdString'); // Debug log
        }

        return {
          'purchaseId': purchaseDoc.id,
          'quantity': purchaseData['quantity'] as int,
          'totalPrice': (purchaseData['totalPrice'] is int)
              ? (purchaseData['totalPrice'] as int).toDouble()
              : purchaseData['totalPrice'] as double,
          'product': {
            'id': productIdString,
            'name': productData['name'] ?? 'Product #$productIdString',
            'price': productData['price'] ?? 0.0,
            'imageUrl': productData['imageUrl'] ?? 'assets/images/placeholder.png',
          }
        };
      }));

      double total = 0.0;
      for (var item in items) {
        total += item['totalPrice'] as double;
      }

      print('Processed ${items.length} cart items with total: $total'); // Debug log

      setState(() {
        cartItems = items;
        cartTotal = total;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e'); // This will show the actual error
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(String purchaseId, int newQuantity, double price) async {
    if (newQuantity < 1) {
      // Remove item from cart
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(purchaseId)
          .delete();
    } else {
      // Update quantity
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(purchaseId)
          .update({
        'quantity': newQuantity,
        'totalPrice': price * newQuantity,
      });
    }

    // Reload cart
    await _loadCartItems();
  }

  Future<void> _proceedToCheckout() async {
    if (cartItems.isEmpty) return;

    // Navigate to checkout screen and pass the total items count and cart total
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          itemCount: cartItems.length,
          cartTotal: cartTotal,
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final product = item['product'];
    final quantity = item['quantity'] as int;
    final purchaseId = item['purchaseId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightOrange.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: true,
            activeColor: orangeTheme,
            onChanged: (value) {
              // Toggle item selection logic would go here
              // For now, all items are selected by default
            },
          ),

          // Product image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textBrown,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${product['price']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: orangeTheme,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              InkWell(
                onTap: () {
                  _updateQuantity(purchaseId, quantity + 1, product['price']);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: orangeTheme),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: orangeTheme,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textBrown,
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  _updateQuantity(purchaseId, quantity - 1, product['price']);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: orangeTheme),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: orangeTheme,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            color: orangeTheme,
          ),
          const SizedBox(width: 8),
          Text(
            'Your Voucher',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textBrown,
            ),
          ),
          const Spacer(),
          Text(
            'Use/Input Code',
            style: TextStyle(
              color: textBrown.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            color: textBrown.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamTheme,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Show cart options menu
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: textBrown.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                color: textBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  color: orangeTheme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cartItems[index]);
              },
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),

          // Voucher section
          _buildVoucherSection(),

          // Divider
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),

          // Checkout section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: textBrown.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '₹${cartTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Checkout Now (${cartItems.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}