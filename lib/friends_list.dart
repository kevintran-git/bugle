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
      stream: Authentication().userChanges, // listen to auth changes
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          if (authSnapshot.hasData) {
            final userRef = FirebaseFirestore.instance
                .collection('users') // grab the user from authenticated data
                .doc(authSnapshot.data!.uid); // grab the user from authenticated data
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

  // grab a list of friends from the user's friends collection
  StreamBuilder<QuerySnapshot<Object?>> friendsListStreamListener(
      DocumentReference userRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: userRef.collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) { // if there is data
          List<QueryDocumentSnapshot> friends = snapshot.data!.docs;
          return friendsListBuilder(friends); // build the list of friends
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // returns the UI for the list of friends
  ListView friendsListBuilder(List<QueryDocumentSnapshot<Object?>> friends) {
    return ListView.builder(
      itemCount: friends.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(height: 75); // take thi
        } else { // build the friend tile
          Friend friend =
          Friend.fromMap(friends[index - 1].data() as Map<String, dynamic>);
          // TODO: go through the database and find the friend with the corresponding UUID
          // then render the friend
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
        }
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
