import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



  Future<void> initializeUserData(User user, DocumentReference userRef) async {
    // Check if the document exists
    final docSnapshot = await userRef.get();
    if (!docSnapshot.exists) {
      // Initialize the user data
      await userRef.set({
        'id': user.uid,
      }, SetOptions(merge: true));
    }
  }
