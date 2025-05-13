import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_care_shop/widgets/pet_category.dart';
import '../screens/shop_screen.dart';

class CategoryItem extends StatelessWidget {
  final PetCategory category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ShopScreen and pass the category name
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopScreen(category: category.name), // Passing category
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                category.icon,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
