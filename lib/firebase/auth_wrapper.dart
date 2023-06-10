import 'package:bugle/firebase/auth.dart';
import 'package:bugle/firebase/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthManager().userChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is logged in
          final user = snapshot.data!;
          // Create a FirestoreDatabase with the user's uid
          final database = FirestoreDatabase(uid: user.uid);
          // Use provider to make the database available to the child widget
          return Provider<FirestoreDatabase>.value(
            value: database,
            child: child,
          );
        } else {
          // User is not logged in
          // Show two buttons: Sign in with Google and Sign in Anonymously
          // When the user taps either button, call the corresponding method in AuthManager
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      AuthManager().signInOrLinkWithGoogle();
                    },
                    child: const Text('Sign in with Google'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AuthManager().signInAnonymously();
                    },
                    child: const Text('Sign in Anonymously (not preferred)'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
