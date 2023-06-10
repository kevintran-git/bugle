// stateful widget
import 'package:bugle/firebase/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/friend.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({Key? key}) : super(key: key);

  // build the list of friends
  @override
  Widget build(BuildContext context) {
    var streamBuilder = StreamBuilder<User?>(
      stream: AuthManager().userChanges, // listen to auth changes
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          if (authSnapshot.hasData) {
            final userRef = FirebaseFirestore.instance
                .collection('users') // grab the user from authenticated data
                .doc(authSnapshot
                    .data!.uid); // grab the user from authenticated data
            return friendsListStreamListener(userRef);
          } else {
            return const Center(child: Text('Please sign in'));
          }
        } else {
          return Viewport(
            offset: ViewportOffset.fixed(100), // set the offset to 100 pixels
            // other properties
            slivers: const [
              // other slivers
              SliverFillRemaining(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
      },
    );

    return Viewport(
      offset: ViewportOffset.fixed(100), // set the offset to 100 pixels
      // other properties
      slivers: [
        // other slivers
        SliverToBoxAdapter(
          child: SizedBox(
            height: 1000.0,
            child: streamBuilder,
          ),
        ),
      ],
    );
  }

  // grab a list of friends from the user's friends collection
  StreamBuilder<QuerySnapshot<Object?>> friendsListStreamListener(
      DocumentReference userRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: userRef.collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // if there is data
          List<QueryDocumentSnapshot> friends = snapshot.data!.docs;
          return friendsListBuilder(friends); // build the list of friends
        } else {
          return Viewport(
            offset: ViewportOffset.fixed(100), // set the offset to 100 pixels
            // other properties
            slivers: const [
              // other slivers
              SliverFillRemaining(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
      },
    );
  }

  // returns the UI for the list of friends
  SliverList friendsListBuilder(List<QueryDocumentSnapshot<Object?>> friends) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return friendsListTile(friends, index, context);
        },
        childCount: friends.length,
      ),
    );
  }

  Widget friendsListTile(List<QueryDocumentSnapshot<Object?>> friends,
      int index, BuildContext context) {
    // build the friend tile
    Friend friend =
        Friend.fromMap(friends[index].data() as Map<String, dynamic>);
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

  //     itemCount: friends.length,
  //     itemBuilder: (context, index) {
  //       Friend friend =
  //           Friend.fromMap(friends[index].data() as Map<String, dynamic>);
  //       // TODO: go through the database and find the friend with the corresponding UUID
  //       // then render the friend
  //       return ListTile(
  //         leading: CircleAvatar(
  //           // check if the profilePictureUrl is null
  //           backgroundImage: friend.profilePictureUrl != ""
  //               ? NetworkImage(friend.profilePictureUrl)
  //               : null,
  //           // first letter of the name
  //           child: Text(friend.name[0]),
  //         ),
  //         title: Text(friend.name,
  //             style: const TextStyle(fontWeight: FontWeight.w400)),
  //         // thinner text. truncate to fit on one line
  //         subtitle: Text(
  //           friend.status,
  //           style: const TextStyle(fontWeight: FontWeight.w300),
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         // onclick
  //         onTap: () {
  //           _showFriendInfoDialog(friend, context);
  //         },
  //       );
  //     },
  //   );
  // }

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
