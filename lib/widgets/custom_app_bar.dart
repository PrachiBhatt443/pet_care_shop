import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onCartPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onCartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().totalItems;
    print('Cart Item Count: $cartItemCount');


    return AppBar(
      backgroundColor: const Color(0xFFA1887F),
      elevation: 0,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
