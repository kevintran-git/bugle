// stateful widget
import 'package:bugle/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/friend.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({Key? key}) : super(key: key);

  // build the list of friends
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Authentication().userChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          if (authSnapshot.hasData) {
            final userRef = FirebaseFirestore.instance
                .collection('users')
                .doc(authSnapshot.data!.uid);
            return friendsListStreamListener(userRef);
          } else {
            return const Center(child: Text('Please sign in'));
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> friendsListStreamListener(
      DocumentReference userRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: userRef.collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> friends = snapshot.data!.docs;
          return friendsListBuilder(friends);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  ListView friendsListBuilder(List<QueryDocumentSnapshot<Object?>> friends) {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        Friend friend =
            Friend.fromMap(friends[index].data() as Map<String, dynamic>);
        return ListTile(
          leading: CircleAvatar(
            // check if the profilePictureUrl is null
            backgroundImage: friend.profilePictureUrl != ""
                ? NetworkImage(friend.profilePictureUrl)
                : null,
            // first letter of the name
            child: Text(friend.name[0]),
          ),
          title: Text(friend.name,
              style: const TextStyle(fontWeight: FontWeight.w400)),
          // thinner text. truncate to fit on one line
          subtitle: Text(
            friend.status,
            style: const TextStyle(fontWeight: FontWeight.w300),
            overflow: TextOverflow.ellipsis,
          ),
          // onclick
          onTap: () {
            _showFriendInfoDialog(friend, context);
          },
        );
      },
    );
  }

  // end build
  void _showFriendInfoDialog(Friend friend, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(friend.name),
          content: Text(friend.status),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
