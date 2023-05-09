import 'dart:async';

import 'package:bugle/auth.dart';
import 'package:bugle/friends_list.dart';
import 'package:bugle/search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'responsive_navigation_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // sign in anonymously only if not already signed in then run app
  if (FirebaseAuth.instance.currentUser == null) {
    await Authentication().signInAnonymously();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.blueAccent;
    // Define the navigation items for the responsive navigation layout.
    // Each item contains an icon, a selected icon, a title, and a screen to navigate to.
    const List<ResponsiveNavigationDestination> destinations =
        <ResponsiveNavigationDestination>[
      ResponsiveNavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        title: 'Schedule',
        screen: FloatingSearchBar(child: FriendsList()),
      ),
      ResponsiveNavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        title: 'Groups',
        screen: MyHomePage(title: 'Groups'),
      ),
      ResponsiveNavigationDestination(
        icon: Icon(Icons.calendar_month_rounded),
        selectedIcon: Icon(Icons.calendar_month),
        title: 'Availability',
        screen: MyHomePage(title: 'Availability'),
      ),
    ];

// This code creates a Material 3 theme and a bottom navigation bar.
// It also creates a ChangeNotifierProvider and a Consumer for app state.
// The app state object is used to track which navigation item is selected.
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Bugle',
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: ThemeData(
          useMaterial3: true, // Enable Material 3 theme
          colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true, // Enable Material 3 theme
          colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor, brightness: Brightness.dark),
        ),
        themeMode: ThemeMode.system, // Follow system theme
        home: Consumer<MyAppState>(
          // Use a Consumer to access app state
          builder: (context, appState, child) {
            // The builder rebuilds the layout when notifyListeners() is called
            return ResponsiveNavigationLayout(
              selectedIndex: appState.selectedIndex,
              destinations: destinations,
              onItemSelected: appState.onItemSelected,
            );
          },
        ),
      ),
    );
  }
}

/// This is the main application class.
/// This class is used to control the state of the application.
class MyAppState extends ChangeNotifier {
  int _selectedIndex =
      0; // This is the current selected index in the navigation bar.

  int get selectedIndex =>
      _selectedIndex; // This getter is used to access the current selected index.

  void onItemSelected(int index) {
    // This method is called when a navigation item is selected.
    _selectedIndex = index;
    notifyListeners(); // This notifies the listeners, which will rebuild the layout.
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // if the user exists, load the user's counter value from Firestore. Otherwise, set the counter value to 0.
  int _counter = 0;

  // create a document reference for the user
  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);
  late StreamSubscription<DocumentSnapshot> userSub;

  // listen to the user document stream in initState
  @override
  void initState() {
    super.initState();
    userSub = userRef.snapshots().listen(
      // handle data event
      (doc) {
        if (doc.exists) {
          setState(() {
            _counter = (doc.data() as Map<String, dynamic>)['counter'] ?? 0;
          });
        }
      },
      // handle error event
      onError: (error) {},
    );
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });

    DocumentSnapshot doc = await userRef.get();
    if (doc.exists) {
      // update the existing document
      userRef.update({'counter': _counter});
    } else {
      // create a new document with set
      userRef.set({'counter': _counter});
    }
  }

  // cancel the stream subscription in dispose
  @override
  void dispose() {
    super.dispose();
    userSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final currentUser = FirebaseAuth.instance.currentUser;

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // This is the current user's display name. only display it if the user is logged in.
            if (currentUser != null)
              Text(
                'Welcome, ${currentUser.uid}!',
              ),
            // space between the display name and the counter
            const SizedBox(height: 12),

            Card(
                color: theme.colorScheme.primary,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: // theme.textTheme.displayMedium
                          Text(
                        '$_counter',
                        style: style.copyWith(fontWeight: FontWeight.w200),
                      ),
                    )))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
