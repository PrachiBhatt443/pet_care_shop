import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? name;
  String? profileImageUrl;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    print("okofdjdk");
    print(user);
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print("doci");
      print(doc);
      if (doc.exists) {
        setState(() {
          username = doc['name'] ?? 'No Name';
          name = doc['email'] ?? '@user';
          profileImageUrl = doc['profile'] ?? ""; // optional
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  // ✅ Logout function added here
  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to login screen and remove all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: Column(
        children: [
          _buildProfileHeader(),
          const Divider(height: 1, thickness: 1),
          _buildSectionHeader('Account'),
          _buildMenuOption(Icons.notifications, 'Notification', Colors.orange),
          _buildMenuOption(Icons.security, 'Privacy and Security', Colors.orange),
          _buildMenuOption(Icons.person_add, 'Add More Accounts', Colors.orange),
          const SizedBox(height: 8),
          _buildSectionHeader('Actions'),
          _buildMenuOption(Icons.language, 'Language', Colors.orange),
          _buildMenuOption(Icons.help, 'Help Center', Colors.orange),
          _buildMenuOption(Icons.logout, 'Log Out', Colors.orange, onTap: _handleLogout),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: profileImageUrl != null
                    ? AssetImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white70,
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            username ?? 'User',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            name ?? '@user',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, Color iconColor, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
