# Bugle

Bugle is a Flutter app that allows you to chat with your friends, schedule events, and manage your availability. Bugle uses Firebase for authentication, storage, and database.

## Features

- Sign in with Google or anonymously
- Add and delete friends
- View friends' status and profile picture
- Create and join groups
- Sync your calendar events with Google Calendar
- Set your availability preferences

## Installation

To run this app, you need to have Flutter installed on your machine. Follow the instructions [here](https://flutter.dev/docs/get-started/install) to set up Flutter.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

You also need to create a Firebase project and enable the following services:

- Firebase Authentication (with Google Sign-In provider)
- Cloud Firestore
- Firebase Storage

Follow the instructions [here](https://firebase.google.com/docs/flutter/setup) to set up Firebase for Flutter.

You need to add the following files to your project:

- android/app/google-services.json (downloaded from Firebase console)
- ios/Runner/GoogleService-Info.plist (downloaded from Firebase console)
- lib/firebase_options.dart (generated by FlutterFire CLI)

## Usage

To run the app in debug mode, use the following command:

```bash
flutter run
```

To build the app for release, use the following command:

```bash
flutter build apk # for Android
flutter build ios # for iOS
```

## Contributing

Please follow the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and the [Dart style guide](https://dart.dev/guides/language/effective-dart/style) for formatting your code.


# Widgets

This document describes the custom widgets that are defined in the source code. 
## Auth Module

This module contains the widgets and classes related to authentication and authorization using Firebase and Google Sign In.

### Authentication Class

This class is a singleton that provides methods for signing in anonymously, signing in or linking with Google, signing out, deleting the user account, and showing a sign out dialog. It also exposes streams and getters for the current user and user changes.

- A singleton class that provides methods for authentication and authorization using Firebase and Google Sign In
- Exposes streams and getters for the current user and user changes
- Provides methods for signing in anonymously, signing in or linking with Google, signing out, deleting the user account, and showing a sign out dialog

### AccountButton Widget

This widget is a stateless widget that displays a circular avatar of the current user if they are signed in with Google, or an elevated button with a login icon if they are anonymous. It also handles the tap events to either show the sign out dialog or sign in with Google.

- A stateless widget that displays a circular avatar of the current user if they are signed in with Google, or an elevated button with a login icon if they are anonymous
- Handles the tap events to either show the sign out dialog or sign in with Google
- Uses a stream builder to get the current user from the Authentication class

## Friends Module

This module contains the widgets and classes related to displaying and managing the friends list of the current user.

### Friend Class

This class is a model class that represents a friend object with fields for id, name, profile picture url, and status. It also provides methods for converting to and from map objects.

- A model class that represents a friend object with fields for id, name, profile picture url, and status
- Provides methods for converting to and from map objects
- Used to store and retrieve friend data from Firestore

### FriendsList Widget

This widget is a stateless widget that builds a list of friends using a stream builder and a list view. It also handles the tap events to show a friend info dialog.

- A stateless widget that builds a list of friends using a stream builder and a list view
- Gets the friend data from Firestore using the current user's document reference
- Handles the tap events to show a friend info dialog using the Friend class

### FriendInfoDialog Widget

This widget is a stateful widget that shows an alert dialog with the name and status of a friend. It also provides an option to close the dialog.

- A stateful widget that shows an alert dialog with the name and status of a friend
- Uses the Friend class to get the friend data
- Provides an option to close the dialog

## Schedule Module

This module contains the widgets and classes related to displaying and managing the schedule of the current user.

### ScheduleWidget Widget

This widget is a stateful widget that displays a calendar view of the current user's schedule. It also allows adding, editing, and deleting events.

- A stateful widget that displays a calendar view of the current user's schedule
- Uses Firebase to store and retrieve schedule data
- Allows adding, editing, and deleting events

## Navigation Module

This module contains the widgets and classes related to navigating between different screens of the app using a responsive navigation layout.

### ResponsiveNavigationLayout Widget

This widget is a stateless widget that adapts to different screen sizes and orientations by using either a navigation rail, a navigation bar, or both. It also handles the selection events and navigates to the corresponding screen.

- A stateless widget that adapts to different screen sizes and orientations by using either a navigation rail, a navigation bar, or both
- Uses a list of ResponsiveNavigationDestination objects to define the navigation destinations
- Handles the selection events and navigates to the corresponding screen

### ResponsiveNavigationDestination Class

This class is a data class that represents a navigation destination with fields for title, icon, selected icon, and screen.

- A data class that represents a navigation destination with fields for title, icon, selected icon, and screen
- Used by the ResponsiveNavigationLayout widget to define the navigation destinations

### FloatingSearchBar Widget

This widget is a stateful widget that displays a floating search bar on top of the app content. It also handles the text input events and performs web searches using Bing.

- A stateful widget that displays a floating search bar on top of the app content
- Uses a text field controller to get the text input from the user
- Performs web searches using Bing and displays the results

### NavigationDrawer Widget

This widget is a stateful widget that displays a drawer menu with options for home, settings, anonymous sign in, and delete account. It also handles the tap events and performs the corresponding actions.














