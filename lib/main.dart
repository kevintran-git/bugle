import 'package:bugle/calendar.dart';
import 'package:bugle/chat.dart';
import 'package:bugle/firebase/auth_wrapper.dart';
import 'package:bugle/friends_screen/friends_screen.dart';
import 'package:bugle/responsive_navigation_layout.dart';
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
    const seedColor = Colors.deepPurple;
    const List<ResponsiveNavigationDestination> destinations =
        <ResponsiveNavigationDestination>[
      ResponsiveNavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        title: 'Schedule',
        screen: AuthWrapper(child: FriendsScreen()),
      ),
      ResponsiveNavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        title: 'Groups',
        screen: Placeholder(),
      ),
      ResponsiveNavigationDestination(
        icon: Icon(Icons.calendar_month_rounded),
        selectedIcon: Icon(Icons.calendar_month),
        title: 'Availability',
        screen: WeekView(),
      ),
    ];

    return MaterialApp(
      title: 'Bugle',
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const ResponsiveNavigationController(allDestinations: destinations),
        '/friendchat': (context) =>
            const AuthWrapper(child: ChatFriendWidget()),
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
    );
  }
}