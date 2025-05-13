import 'package:flutter/material.dart';
import '../screens/shop_screen.dart';

class PetCategoryGrid extends StatelessWidget {
  final List<PetCategory> categories = [
    PetCategory(name: 'Food', icon: 'assets/images/pet-food.png'),
    PetCategory(name: 'Grooming', icon: 'assets/images/grooming.png'),
    PetCategory(name: 'Toys', icon: 'assets/images/dog-toy.png'),
    PetCategory(name: 'Care', icon: 'assets/images/medicine.png'),
    PetCategory(name: 'Fashion', icon: 'assets/images/clothes.png'),
    PetCategory(name: 'Furniture', icon: 'assets/images/pet-bed.png'),
    PetCategory(name: 'Accessories', icon: 'assets/images/leash.png'),
    PetCategory(name: 'Other', icon: 'assets/images/veterinary.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryItem(category: categories[index]);
            },
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final PetCategory category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopScreen(category: category.name), // Pass category here
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

class PetCategory {
  final String name;
  final String icon;

  PetCategory({required this.name, required this.icon});
}
