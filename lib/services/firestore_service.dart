import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Example: Get data from Firestore
  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      return doc;
    } catch (e) {
      throw e.toString();
    }
  }
}
// AyIzaSyCXB8lpmDW0wPs0rMEFfZCJ1hwp2uGSDrk