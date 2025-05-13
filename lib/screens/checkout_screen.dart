// import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final int itemCount;
  final double cartTotal;

  const CheckoutScreen({
    Key? key,
    required this.itemCount,
    required this.cartTotal,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Theme colors (matching cart screen)
  final orangeTheme = const Color(0xFFFFA726);
  final creamTheme = const Color(0xFFFFF8E1);
  final lightOrange = const Color(0xFFFFE0B2);
  final textBrown = const Color(0xFF8D6E63);
  final buttonOrange = const Color(0xFFE67E22);

  // Form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  // Delivery options
  final List<Map<String, dynamic>> _deliveryOptions = [
    {
      'name': 'Standard Delivery',
      'description': '3-5 business days',
      'price': 40.0,
      'icon': Icons.local_shipping,
    },
    {
      'name': 'Express Delivery',
      'description': '1-2 business days',
      'price': 80.0,
      'icon': Icons.delivery_dining,
    },
    {
      'name': 'Same Day Delivery',
      'description': 'Within 24 hours',
      'price': 120.0,
      'icon': Icons.directions_run,
    },
  ];

  int _selectedDeliveryIndex = 0;
  bool _isProcessing = false;

  // Get total amount including delivery
  double get totalAmount => widget.cartTotal + _deliveryOptions[_selectedDeliveryIndex]['price'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentModal(
        totalAmount: totalAmount,
        onPaymentComplete: _processOrder,
      ),
    );
  }

  Future<void> _processOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

      // Get all pending purchases
      final purchasesSnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .where('status', isEqualTo: 'Pending')
          .where('userId', isEqualTo: userId)
          .get();

      // Update each purchase to 'Paid' status
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in purchasesSnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'Paid',
          'paidAt': FieldValue.serverTimestamp(),
          'deliveryOption': _deliveryOptions[_selectedDeliveryIndex]['name'],
          'deliveryFee': _deliveryOptions[_selectedDeliveryIndex]['price'],
          'shippingAddress': {
            'name': _nameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'zip': _zipController.text,
            'phone': _phoneController.text,
          }
        });
      }

      await batch.commit();

      // Create a new order record
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'orderDate': FieldValue.serverTimestamp(),
        'totalAmount': totalAmount,
        'itemCount': widget.itemCount,
        'status': 'Processing',
        'deliveryDetails': {
          'option': _deliveryOptions[_selectedDeliveryIndex]['name'],
          'fee': _deliveryOptions[_selectedDeliveryIndex]['price'],
        },
        'shippingAddress': {
          'name': _nameController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip': _zipController.text,
          'phone': _phoneController.text,
        }
      });

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      print('Error processing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing your order: $e'))
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderSuccessDialog(
        onContinue: () {
          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildDeliveryOption(int index) {
    final option = _deliveryOptions[index];
    final isSelected = _selectedDeliveryIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDeliveryIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? lightOrange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? orangeTheme : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option['icon'],
              color: isSelected ? orangeTheme : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textBrown,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    option['description'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${option['price'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: orangeTheme,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? orangeTheme : Colors.grey,
            ),
          ],
        ),
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
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textBrown,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items (${widget.itemCount})',
                        style: TextStyle(color: textBrown),
                      ),
                      Text(
                        '₹${widget.cartTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee',
                        style: TextStyle(color: textBrown),
                      ),
                      Text(
                        '₹${_deliveryOptions[_selectedDeliveryIndex]['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textBrown,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textBrown,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: orangeTheme,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Shipping Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textBrown,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // Shipping form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.home,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.map,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _zipController,
                          label: 'Zip Code',
                          icon: Icons.pin_drop,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Delivery Options',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textBrown,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // Delivery options
            for (int i = 0; i < _deliveryOptions.length; i++)
              _buildDeliveryOption(i),

            const SizedBox(height: 24),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showPaymentModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed to Payment - ₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textBrown.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: orangeTheme),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: orangeTheme),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class PaymentModal extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPaymentComplete;

  const PaymentModal({
    Key? key,
    required this.totalAmount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final orangeTheme = const Color(0xFFFFA726);
  final creamTheme = const Color(0xFFFFF8E1);
  final textBrown = const Color(0xFF8D6E63);
  final buttonOrange = const Color(0xFFE67E22);

  String _selectedPaymentMethod = 'creditCard';
  bool _isProcessing = false;
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Call the completion callback
    widget.onPaymentComplete();

    // Close the payment modal
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textBrown,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textBrown),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payment methods
          _buildPaymentMethodOption(
            title: 'Credit/Debit Card',
            value: 'creditCard',
            icon: Icons.credit_card,
          ),

          _buildPaymentMethodOption(
            title: 'UPI Payment',
            value: 'upi',
            icon: Icons.account_balance,
          ),

          _buildPaymentMethodOption(
            title: 'Cash on Delivery',
            value: 'cod',
            icon: Icons.money,
          ),

          const SizedBox(height: 24),

          // Card details form (visible only for credit card option)
          if (_selectedPaymentMethod == 'creditCard') ...[
            TextField(
              controller: _cardNumberController,
              decoration: _inputDecoration(
                'Card Number',
                'XXXX XXXX XXXX XXXX',
                Icons.credit_card,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _cardHolderController,
              decoration: _inputDecoration(
                'Card Holder Name',
                'John Doe',
                Icons.person,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: _inputDecoration(
                      'Expiry Date',
                      'MM/YY',
                      Icons.calendar_today,
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: _inputDecoration(
                      'CVV',
                      'XXX',
                      Icons.lock,
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                  ),
                ),
              ],
            ),
          ] else if (_selectedPaymentMethod == 'upi') ...[
            TextField(
              decoration: _inputDecoration(
                'UPI ID',
                'username@upi',
                Icons.account_balance_wallet,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Total amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: creamTheme,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(
                    color: textBrown,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: orangeTheme,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pay now button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                _selectedPaymentMethod == 'cod'
                    ? 'Place Order'
                    : 'Pay Now - ₹${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Secure payment note
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Make space for keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? creamTheme : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? orangeTheme : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? orangeTheme : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? textBrown : Colors.black87,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? orangeTheme : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: orangeTheme),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: orangeTheme, width: 2),
      ),
    );
  }
}

class OrderSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const OrderSuccessDialog({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orangeTheme = const Color(0xFFFFA726);
    final textBrown = const Color(0xFF8D6E63);
    final buttonOrange = const Color(0xFFE67E22);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: orangeTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: orangeTheme,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textBrown,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your order has been placed successfully. You will receive a confirmation email shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you for shopping with us!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textBrown,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late int itemCount;
//   late List<String> purchaseIds;
//   late double totalAmount;
//   bool isPlacingOrder = false;
//
//   final orangeTheme = const Color(0xFFFFA726);
//   final creamTheme = const Color(0xFFFFF8E1);
//   final textBrown = const Color(0xFF8D6E63);
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args =
//     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
//     itemCount = args['itemCount'];
//     purchaseIds = List<String>.from(args['purchaseIds']);
//     totalAmount = args['totalAmount'];
//   }
//
//   Future<void> _placeOrder() async {
//     setState(() => isPlacingOrder = true);
//
//     try {
//       // Update purchase status to 'Placed'
//       for (String id in purchaseIds) {
//         await FirebaseFirestore.instance
//             .collection('purchases')
//             .doc(id)
//             .update({'status': 'Placed'});
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order placed successfully!')),
//       );
//
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error placing order: $e')),
//       );
//     } finally {
//       setState(() => isPlacingOrder = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: creamTheme,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         title: const Text(
//           'Checkout',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Order Summary
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Order Summary',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: textBrown,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Items ($itemCount)', style: TextStyle(color: textBrown)),
//                       Text('₹${totalAmount.toStringAsFixed(2)}',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   const Divider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total Amount',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: textBrown)),
//                       Text('₹${totalAmount.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Payment Method (mock)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: orangeTheme.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.payment, color: orangeTheme),
//                   const SizedBox(width: 12),
//                   Text('Pay on Delivery',
//                       style: TextStyle(
//                           color: textBrown, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//             const Spacer(),
//
//             // Place Order Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: orangeTheme,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: isPlacingOrder ? null : _placeOrder,
//                 child: isPlacingOrder
//                     ? const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 )
//                     : const Text(
//                   'Place Order',
//                   style: TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
