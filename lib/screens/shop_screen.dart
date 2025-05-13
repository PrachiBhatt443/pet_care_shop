import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care_shop/screens/product_details_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/pet_category.dart';

class ShopScreen extends StatefulWidget {
  final String category;

  const ShopScreen({Key? key, required this.category}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String selectedCategory = 'All';
  String selectedType = 'All';
  String searchText = '';

  final List<PetCategory> categories = [
    PetCategory(name: 'All', icon: 'assets/images/pet-food.png'),
    PetCategory(name: 'Food', icon: 'assets/images/pet-food.png'),
    PetCategory(name: 'Grooming', icon: 'assets/images/grooming.png'),
    PetCategory(name: 'Toys', icon: 'assets/images/dog-toy.png'),
    PetCategory(name: 'Care', icon: 'assets/images/medicine.png'),
    PetCategory(name: 'Fashion', icon: 'assets/images/clothes.png'),
    PetCategory(name: 'Furniture', icon: 'assets/images/pet-bed.png'),
    PetCategory(name: 'Accessories', icon: 'assets/images/leash.png'),
    PetCategory(name: 'Other', icon: 'assets/images/veterinary.png'),
  ];

  final List<String> animalTypes = ['All', 'Dog', 'Cat'];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔍 Search Bar + 🐶 Type Dropdown
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => searchText = value),
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search, color: Colors.brown),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedType,
                    icon: const Icon(Icons.pets),
                    underline: Container(height: 2, color: Colors.orange),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: animalTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔘 Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat.name,
                        onSelected: (_) =>
                            setState(() => selectedCategory = cat.name),
                        selectedColor: Colors.orange.shade200,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 🛍 Product Grid
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('products').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No products found."));
                    }

                    // ✅ Filter and build product list
                    final filteredProducts = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final matchesCategory = selectedCategory == 'All' ||
                          data['category'] == selectedCategory;

                      final matchesType = selectedType == 'All' ||
                          (data['type']?.toLowerCase() == selectedType.toLowerCase());

                      final keywords = searchText.toLowerCase().split(' ').where((kw) => kw.isNotEmpty);

                      final matchesSearch = searchText.isEmpty || keywords.every((kw) =>
                          [
                            data['name'],
                            data['description'],
                            data['category'],
                            data['type'],
                          ].any((field) =>
                          field != null && field.toString().toLowerCase().contains(kw)));

                      return matchesCategory && matchesType && matchesSearch;
                    }).toList();

                    return GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final data = filteredProducts[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: data),
                              ),
                            );
                          },
                          child: ProductCard(
                            imageUrl: data['imageUrl'],
                            title: data['name'],
                            description: data['description'],
                            price: (data['price'] ?? 0).toDouble(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
