// auth.dart
import 'package:bugle/models/data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {
  // Singleton
  static final AuthManager _instance =
      AuthManager._internal(); // creates singleton
  factory AuthManager() =>
      _instance; // links every call to the constructor to the same instance
  AuthManager._internal(); // private constructor

  static const _clientId = kIsWeb
      ? String.fromEnvironment("FIREBASE_CLIENTID_WEB")
      : String.fromEnvironment("FIREBASE_CLIENTID_IOS");

  // Firebase and Google Sign In objects
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    // GoogleSignIn object, this is used for the Google Sign In flow and Calendar access
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.events.readonly',
    ],
    clientId: _clientId,
  );

  // Public getters for the current user and auth state
  User? get _currentUser => _firebaseAuth.currentUser;
  DocumentReference get _currentUserRef =>
      FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid);
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      createNewUser();
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in anonymously: $e');
      }
      return null;
    }
  }

  Future<OAuthCredential?> authenticateWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      createNewUser();

      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Error authenticating with Google: $e');
      }
      return null;
    }
  }

  Future<void> createNewUser() async {
    var userDoc = await _currentUserRef.get();
    if (!userDoc.exists) {
      final newUser = UserDataModel(
        friends: [],
        requestsInbox: [],
        requestsOutgoing: [],
        availability: [],
        displayName: _currentUser!.uid,
        id: _currentUser!.uid,
      );
      await _currentUserRef.set(newUser.toMap());
    }
  }

  // Updates the user data with the given user object
  Future<void> _updateUserInfo() async {
    // Update the user info with the credential user
    // gets the current user data
    final userDoc = await _currentUserRef.get();
    final currentUser =
        UserDataModel.fromMap(userDoc.data() as Map<String, dynamic>);
    
    // if currentUser is null, return
    if (_currentUser == null) return;

    // potentially gets new user data
    final displayName = _currentUser!.providerData[0].displayName;
    final email = _currentUser!.providerData[0].email;
    final profilePictureUrl = _currentUser!.providerData[0].photoURL;

    // creates a new user object with the new data
    final newUser = UserDataModel(
      displayName: displayName ?? currentUser.displayName,
      email: email ?? currentUser.email,
      profilePictureUrl: profilePictureUrl ?? currentUser.profilePictureUrl,
      availability: currentUser.availability,
      id: currentUser.id, 
      friends: currentUser.friends, 
      requestsInbox: currentUser.requestsInbox, 
      requestsOutgoing: currentUser.requestsOutgoing,
    );

    _currentUserRef.update(newUser.toMap());
  }

  Future<void> signInOrLinkWithGoogle() async {
    final OAuthCredential? credential = await authenticateWithGoogle();

    try {
      if (credential == null) return;
      final currentUser = _firebaseAuth.currentUser;

      // If the user is anonymous, link the Google credential to the anonymous account
      if (currentUser != null && currentUser.isAnonymous) {
        await currentUser.linkWithCredential(credential);
        // Update the user info
      } else {
        // Otherwise, sign in with Google credential
        await _firebaseAuth.signInWithCredential(credential);
      }
      await _updateUserInfo();
    } on FirebaseAuthException catch (e) {
      await deleteUser();
      // Sign in with Google credential
      await _firebaseAuth.signInWithCredential(credential!);
      await _updateUserInfo();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteUser() async {
    // delete if the user is anonymous
    if (_currentUser?.isAnonymous ?? false) {
      // var friends = _currentUserRef.collection('friends');
      // await friends.get().then((snapshot) {
      //   for (DocumentSnapshot ds in snapshot.docs) {
      //     ds.reference.delete();
      //   }
      // });
      await _currentUserRef.delete(); // delete user data
      await _currentUser?.delete(); // delete user
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  // Shows a Dialog to sign the user out. Displays the user's name, email, uid. Options are to cancel and sign out
  Future<void> showSignOutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final User? user = _currentUser;
        if (user == null) {
          return const AlertDialog(title: Text("No user signed in"));
        }
        return AlertDialog(
          title: Text(user.displayName ?? "Anonymous"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(user.email ?? "No email"),
                Text("Is anonymous: ${user.isAnonymous}"),
                // are they signed in using google
                Text(user.uid),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign out'),
              onPressed: () async {
                await signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
