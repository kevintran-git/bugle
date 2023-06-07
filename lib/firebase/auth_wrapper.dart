import 'package:bugle/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  // The widget that requires authentication
  final Widget child;

  const AuthWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the user stream from the auth class
    return StreamBuilder<User?>(
      stream: AuthManager().userChanges,
      builder: (context, snapshot) {
        // If the user is not null, pass it to the child widget
        if (snapshot.hasData && snapshot.data != null) {
          return child;
        }
        // Otherwise, show a sign in button
        else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
