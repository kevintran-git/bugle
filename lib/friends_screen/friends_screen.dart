import 'package:bugle/firebase/auth.dart';
import 'package:bugle/firebase/firestore.dart';
import 'package:bugle/friends_screen/search_bar.dart';
import 'package:bugle/models/data_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: FriendsDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            FriendsSearchBar(),
            FriendsListSliver(),
          ],
        ),
      ),
    );
  }
}

class FriendsDrawer extends StatelessWidget {
  const FriendsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        // The drawer content goes here
        ListTile(
          title: const Text('Home'),
          leading: const Icon(Icons.home),
          onTap: () async {
            // Navigate to home screen
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: () {
            // Navigate to settings screen
            Navigator.pop(context);
            AuthManager().showSignOutDialog(context);
          },
        ),
        ListTile(
          title: const Text('Anonymous'),
          leading: const Icon(Icons.login),
          onTap: () {
            AuthManager().signInAnonymously();
            Navigator.pop(context);
          },
        ),
        // delete account
        ListTile(
          title: const Text('Delete Account'),
          leading: const Icon(Icons.delete),
          onTap: () {
            AuthManager().deleteUser();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class FriendsListSliver extends StatelessWidget {
  const FriendsListSliver({super.key});

  Widget friendsListTile(UserDataModel friend, BuildContext context) {
    final status = friend.email == null ? 'Anonymous' : "@${friend.email?.substring(0, friend.email?.indexOf('@'))}";
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(friend.profilePictureUrl ?? ''),),
      title: Text(friend.displayName,
          style: const TextStyle(fontWeight: FontWeight.w400)),
      // thinner text. truncate to fit on one line
      subtitle: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.w300),
        overflow: TextOverflow.ellipsis,
      ),
      // onclick
      onTap: () {
        Navigator.pushNamed(context, '/friendchat',
            arguments: friend);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<FirestoreDatabase>(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // A header for the friend requests section
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text(
          //     'Friend Requests',
          //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          // ),
          // A stream builder that listens to the requests inbox stream from the friends method
          StreamBuilder<List<UserDataModel>>(
            stream: database.requestsInboxStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // A list view builder that creates a tile for each request in the inbox
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    // A variable to store the current request user data
                    final requestUser = snapshot.data![index];
                    return ListTile(
                      // A leading widget that shows the profile picture of the request user
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(requestUser.profilePictureUrl ?? ''),
                      ),
                      // A title widget that shows the display name of the request user
                      title: Text(requestUser.displayName),
                      // A subtitle widget that shows the email of the request user
                      subtitle: Text(requestUser.email == null ? 'Anonymous' : "@${requestUser.email?.substring(0, requestUser.email?.indexOf('@'))}"),
                      // A trailing widget that shows two buttons for accepting and declining the request
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // A button that calls the handleFriendRequest method with true as the accepted parameter
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              database.handleFriendRequest(
                                  requestUser.id, true);
                            },
                          ),
                          // A button that calls the handleFriendRequest method with false as the accepted parameter
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              database.handleFriendRequest(
                                  requestUser.id, false);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                // A circular progress indicator to show while loading the data
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // A divider to separate the friend requests and the friends sections
          const Divider(),
          // // A header for the friends section
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text(
          //     'Friends',
          //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          // ),
          // A stream builder that listens to the friends stream from the friends method
          StreamBuilder<List<UserDataModel>>(
            stream: database.friendsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // A list view builder that creates a tile for each friend in the list
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    // A variable to store the current friend user data
                    final friendUser = snapshot.data![index];
                    return friendsListTile(friendUser, context);
                  },
                );
              } else {
                // A circular progress indicator to show while loading the data
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}

// ListTile(
// // A leading widget that shows the profile picture of the friend user
// leading: CircleAvatar(
// backgroundImage:
// NetworkImage(friendUser.profilePictureUrl ?? ''),
// ),
// // A title widget that shows the display name of the friend user
// title: Text(friendUser.displayName),
// // A subtitle widget that shows the availability of the friend user
// onTap: () {
// // Navigate to the chat screen
// Navigator.pushNamed(context, '/friendchat',
// arguments: friendUser);
// },
// );