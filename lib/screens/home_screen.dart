import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care_shop/screens/shop_screen.dart';
import 'package:pet_care_shop/screens/vet_screen.dart';
import 'package:pet_care_shop/screens/profile_screen.dart';
import '../widgets/welcome_header.dart';
import '../widgets/promotion_carousel.dart';
import '../widgets/pet_category.dart';
import '../widgets/custom_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  // Pages should be dynamically created based on _selectedIndex
  final List<Widget> _pages = [
    HomeContent(),
    ShopScreen(category: 'All'),  // Set a default category
    VetScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Change the title based on the selected index
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Shop';
      case 2:
        return 'Vet';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF2), // Soft off-white cream
        appBar: CustomAppBar(
          title: _getAppBarTitle(), // Just the string now
          onCartPressed: () {
            // Navigate to the cart screen
          },
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFE0B2), // Light orange
        selectedItemColor: Color(0xFFEF6C00), // Burnt orange
        unselectedItemColor: Color(0xFF6D4C41), // Muted brown
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Vet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _loadUsername();
  }
  Future<void> _handleLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Request permission
    PermissionStatus status = await Permission.location.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      // Optionally show dialog to inform the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location permission is required for best experience'),
      ));
    }
  }

  Future<void> _loadUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            username = doc.data()?['name'] ?? 'User';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading username: $e');
      setState(() {
        username = 'User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        WelcomeHeader(username: username ?? 'User'),
        SizedBox(height: 16),
        PromotionCarousel(),
        SizedBox(height: 16),
        PetCategoryGrid(),
        SizedBox(height: 24),
      ],
    );
  }
}
