import 'package:bugle/chat.dart';
import 'package:bugle/firebase/auth_wrapper.dart';
import 'package:bugle/friends_screen/friends_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // sign in anonymously only if not already signed in then run app
  // if (FirebaseAuth.instance.currentUser == null) {
  //   await Authentication().signInAnonymously();
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.blue;

    return MaterialApp(
      title: 'Bugle',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(child: FriendsScreen()),
        //'/chat': (context) => const ChatWidget(),
        '/friendchat': (context) => const ChatFriendWidget(),
      },
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3 theme
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
            shadow: Colors.transparent),
      ),
      darkTheme: ThemeData(
        useMaterial3: true, // Enable Material 3 theme
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
            shadow: Colors.transparent),
      ),
      themeMode: ThemeMode.system, // Follow system theme
      // home: const AuthWrapper(child: FriendsScreen()),
    );
    // Define the navigation items for the responsive navigation layout.
    // Each item contains an icon, a selected icon, a title, and a screen to navigate to.
    // const List<ResponsiveNavigationDestination> destinations =
    //     <ResponsiveNavigationDestination>[
    //   ResponsiveNavigationDestination(
    //     icon: Icon(Icons.chat_bubble_outline),
    //     selectedIcon: Icon(Icons.chat_bubble),
    //     title: 'Schedule',
    //     screen: AuthWrapper(child: FriendsScreen()),
    //   ),
    //   ResponsiveNavigationDestination(
    //     icon: Icon(Icons.people_outline),
    //     selectedIcon: Icon(Icons.people),
    //     title: 'Groups',
    //     screen: Placeholder(),
    //   ),
    //   ResponsiveNavigationDestination(
    //     icon: Icon(Icons.calendar_month_rounded),
    //     selectedIcon: Icon(Icons.calendar_month),
    //     title: 'Availability',
    //     screen: ChatWidget(),
    //   ),
    // ];

// This code creates a Material 3 theme and a bottom navigation bar.
// It also creates a ChangeNotifierProvider and a Consumer for app state.
// The app state object is used to track which navigation item is selected.
    // return ChangeNotifierProvider(
    //   create: (context) => MyAppState(),
    //   child: MaterialApp(
    //     title: 'Bugle',
    //     debugShowCheckedModeBanner: false, // Remove debug banner
    //     theme: ThemeData(
    //       useMaterial3: true, // Enable Material 3 theme
    //       colorScheme: ColorScheme.fromSeed(
    //           seedColor: seedColor,
    //           brightness: Brightness.light,
    //           shadow: Colors.transparent),
    //     ),
    //     darkTheme: ThemeData(
    //       useMaterial3: true, // Enable Material 3 theme
    //       colorScheme: ColorScheme.fromSeed(
    //           seedColor: seedColor,
    //           brightness: Brightness.dark,
    //           shadow: Colors.transparent),
    //     ),
    //     themeMode: ThemeMode.system, // Follow system theme
    //     home: Consumer<MyAppState>(
    //       // Use a Consumer to access app state
    //       builder: (context, appState, child) {
    //         // The builder rebuilds the layout when notifyListeners() is called
    //         return ResponsiveNavigationLayout(
    //           selectedIndex: appState.selectedIndex,
    //           destinations: destinations,
    //           onItemSelected: appState.onItemSelected,
    //         );
    //       },
    //     ),
    //   ),
    // );
  }
}

// /// This is the main application class.
// /// This class is used to control the state of the application.
// class MyAppState extends ChangeNotifier {
//   int _selectedIndex =
//       0; // This is the current selected index in the navigation bar.

//   int get selectedIndex =>
//       _selectedIndex; // This getter is used to access the current selected index.

//   void onItemSelected(int index) {
//     // This method is called when a navigation item is selected.
//     _selectedIndex = index;
//     notifyListeners(); // This notifies the listeners, which will rebuild the layout.
//   }
//}
