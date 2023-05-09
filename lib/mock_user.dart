import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/friend.dart';

Future<void> populateDatabaseWithFakeFriends(User currentUser) async {
  final faker = Faker();
  final friendsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('friends');

  for (int i = 0; i < 10; i++) {
    final fakeFriend = Friend(
      id: faker.guid.guid(),
      name: faker.person.name(),
      profilePictureUrl: '',
      status: faker.lorem.sentence(),
    );

    await friendsCollection.doc(fakeFriend.id).set(fakeFriend.toMap());
  }
}

  Future<void> initializeUserData(User user, DocumentReference userRef) async {
    // Check if the document exists
    final docSnapshot = await userRef.get();
    if (!docSnapshot.exists) {
      // Initialize the user data
      await userRef.set({
        'id': user.uid,
      }, SetOptions(merge: true));

      await populateDatabaseWithFakeFriends(user);
    }
  }
