import 'package:bugle/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthProvider().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null && !user.isAnonymous) {
            // avatar of the user. if on click, display dialog
            return InkWell(
              onTap: () {
                AuthProvider().showSignOutDialog(context);
              },
              child: CircleAvatar(
                // placeholder if no photoURL
                backgroundImage: NetworkImage(user.providerData[0].photoURL ??
                    'https://via.placeholder.com/150'),
                radius: 16,
              ),
            );
          } else {
            return ElevatedButton.icon(
              onPressed: () async {
                await AuthProvider().signInOrLinkWithGoogle();
              },
              icon: const Icon(Icons.login, size: 16),
              label: const Text('Sign in'),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
