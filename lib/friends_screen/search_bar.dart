import 'package:bugle/firebase/firestore.dart';
import 'package:bugle/friends_screen/account_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/data_models.dart';

class FriendsSearchBar extends StatelessWidget {
  const FriendsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<FirestoreDatabase>(context);
      return SliverAppBar (
      clipBehavior: Clip.none, // content won't be clipped
      shape: const StadiumBorder(),
      elevation: 0,
      titleSpacing: 5.0,
      backgroundColor: Colors.transparent,
      floating: true,
      title: SearchAnchor.bar(
        barHintText: 'Search for a friend',
        //barLeading: _buildLeading(context),
        barTrailing: const [AccountButton(),],
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          return _buildSuggestions(context, controller, database);
        },
      ),
    );
    // return SearchAnchor.bar(
    //   barHintText: 'Search for a friend',
    //   barLeading: _buildLeading(context),
    //   barTrailing: const [
    //     AccountButton(),
    //   ],
    //   suggestionsBuilder: (BuildContext context, SearchController controller) {
    //     return _buildSuggestions(context, controller, database);
    //   },
    // );
  
  }

  Widget _buildLeading(BuildContext context) {
    return Builder(
      // this builder is needed to provide a context for the IconButton below
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open the drawer
            Scaffold.of(context).openDrawer(); // opens the side drawer
          },
        );
      },
    );
  }

  // method for generating a list of suggestions
  Iterable<Widget> _buildSuggestions(BuildContext context,
      SearchController controller, FirestoreDatabase database) {
    // Get the current query from the controller
    String query = controller.text;

    // Check if the query is empty or null
    if (query.isEmpty) {
      // Return an empty list of widgets
      return [];
    }

    // Call the searchUsers method and assign it to a future variable
    bool isEmailSearch = query.contains('@');
    Future<List<UserDataModel>> future;

    if (isEmailSearch) {
      future = database.searchUsersByEmail(query);
    } else {
      // Otherwise, call the searchUsers method
      future = database.searchUsers(query);
    }

    // Return a FutureBuilder widget that takes the future and a builder function as arguments
    final futureBuilder = FutureBuilder(
      // Pass the future variable to the future argument
      future: future,
      // Define the builder function that takes the context and the snapshot of the future as parameters
      builder: (context, snapshot) {
        // Check the state of the snapshot
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the snapshot is waiting, return a CircularProgressIndicator widget
          return const LinearProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          // If the snapshot is done, check if it has data
          if (snapshot.hasData) {
            // If the snapshot has data, get the list of users from the data
            List<UserDataModel> users = snapshot.data!;

            // Return a list of widgets that map each user to a UserTile widget
            return ListView.builder(
              shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
              itemBuilder: (BuildContext context, int index){
                  return UserTile(user: users[index], isEmailSearch: isEmailSearch, database: database);
            });
          } else if (snapshot.hasError) {
            // If the snapshot has an error, return a Text widget with the error message
            return Text(snapshot.error.toString());
          } else {
            // If the snapshot has no data and no error, return an empty list of widgets
            return const LinearProgressIndicator();
          }
        } else {
          // If the snapshot has any other state, return an empty list of widgets
          return const LinearProgressIndicator();
        }
      },
    );

    return [futureBuilder];

    // Check if the query contains an @ symbol
    //bool isEmailSearch = query.contains('@');

 

    // // Declare a future to store the async operation of searching users
    // Future<List<UserDataModel>> future;

    // if (isEmailSearch) {
    //   future = database.searchUsersByEmail(query);
    // } else {
    //   // Otherwise, call the searchUsers method
    //   future = database.searchUsers(query);
    // }

    // Wait for the future to complete and assign the result to the users list
    //future.then((value) => users = value);

    // print(users.length);
  }
}

// A widget that displays a tile for a user
class UserTile extends StatelessWidget {
  final UserDataModel user;
  final bool isEmailSearch;
  final FirestoreDatabase database;

  const UserTile({super.key, required this.user, required this.isEmailSearch, required this.database});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person), // Show a generic icon for email search
      title: Text(isEmailSearch
          ? (user.email ??
              user.displayName) // Show email or username depending on the search type
          : user.displayName),
      onTap: () {
        // Do something when the tile is tapped
        database.sendFriendRequest(user.id);
      },
    );
  }
}

// // A widget that displays a list of tiles for a list of users
// class UserList extends StatelessWidget {
//   final List<UserDataModel> users;
//   final bool isEmailSearch;

//   const UserList({super.key, required this.users, required this.isEmailSearch});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: users.length,
//       itemBuilder: (context, index) {
//         return UserTile(
//           user: users[index],
//           isEmailSearch: isEmailSearch,
//         );
//       },
//     );
//   }
// }
