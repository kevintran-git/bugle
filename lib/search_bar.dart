import 'package:bugle/account_button.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class FloatingSearchBar extends StatefulWidget {
  final Widget child;

  const FloatingSearchBar({Key? key, required this.child}) : super(key: key);

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // The rest of the app content goes here
            widget.child,
            // The floating search bar
            Positioned(
              top: 10.0,
              left: 16.0,
              right: 16.0,
              child: SearchBar(
                leading: Builder( // this builder is needed to provide a context for the IconButton below
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        // Open the drawer
                        Scaffold.of(context).openDrawer(); // opens the side drawer
                      },
                    );
                  },
                ),
                controller: _controller,
                hintText: 'Search',
                trailing: const [AccountButton(),],
              ),
            ), // end searchbar
          ],
        ),
      ),
      drawer: NavigationDrawer(
        children: [
          // The drawer content goes here
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
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
              Authentication().showSignOutDialog(context);
            },
          ),
          ListTile(
            title: const Text('Anonymous'),
            leading: const Icon(Icons.login),
            onTap: () {
              Authentication().signInAnonymously();
              Navigator.pop(context);
            },
          ),
          // delete account
          ListTile(
            title: const Text('Delete Account'),
            leading: const Icon(Icons.delete),
            onTap: () {
              Authentication().deleteUser();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Perform some action
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
