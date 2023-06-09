import 'package:bugle/models/data_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  final String uid;
  FirestoreDatabase({required this.uid});
  final userCollection = FirebaseFirestore.instance.collection('users');
 
  // updates a user's data, if the userId is not provided, it will update the current user's data
  Future<void> updateUser(UserDataModel user, [String? userId]) async {
    await userCollection.doc(userId ?? uid).update(user.toMap());
  }

  // Notifies when the user's data changes
  Stream<UserDataModel> userStream([String? userId]) {
    return userCollection
        .doc(userId ?? uid)
        .snapshots()
        .map((user) => UserDataModel.fromMap(user.data()!));
  }

  // Gets a user from the database
  Future<UserDataModel> _getUser([String? userId]) async {
    final userDoc = await userCollection.doc(userId ?? uid).get();
    final userData = userDoc.data();
    if (userData != null) {
      return UserDataModel.fromMap(userData);
    } else {
      throw Exception('User not found');
    }
  }

  // Sends a friend request from the current user to the target user
  Future<void> sendFriendRequest(String targetUserId) async {
    final targetUser = await _getUser(targetUserId);
    final currentUser = await _getUser();

    // check if there is already a pending friend request or if the target user is the current user
    if (targetUser.requestsInbox.contains(uid) ||
        currentUser.requestsOutgoing.contains(targetUserId) || targetUserId == uid) {
      return;
    }

    // add the target user to the current user's sent friend requests
    currentUser.requestsOutgoing.add(targetUserId);
    await updateUser(currentUser);

    // add the current user to the target user's received friend requests
    targetUser.requestsInbox.add(uid);
    await updateUser(targetUser, targetUserId);
  }

  // Handles a friend request from the target user to the current user
  Future<void> handleFriendRequest(String targetUserId, bool accepted) async {
    final targetUser = await _getUser(targetUserId);
    final currentUser = await _getUser();

    // check if the target user has sent a friend request to the current user
    if (!targetUser.requestsOutgoing.contains(uid) ||
        !currentUser.requestsInbox.contains(targetUserId)) {
      throw Exception('No friend request found');
    }

    // remove the target user from the current user's received friend requests
    currentUser.requestsInbox.remove(targetUserId);

    if (accepted) {
      // add the target user to the current user's friends
      currentUser.friends.add(targetUserId);
    }

    await updateUser(currentUser);

    // remove the current user from the target user's sent friend requests
    targetUser.requestsOutgoing.remove(uid);

    if (accepted) {
      // add the current user to the target user's friends
      targetUser.friends.add(uid);
    }

    await updateUser(targetUser, targetUserId);
  }

  // Gets a list of users by their ids
  Future<List<UserDataModel>> _getUsersByIds(List<String> userIds) async {
    return Future.wait(userIds.map((userId) => _getUser(userId)));
  }

  // stream of the user's friends
  Stream<List<UserDataModel>> friendsStream() {
    return userStream().map((user) => user.friends).asyncMap(_getUsersByIds);
  }

  // stream of the user's friend requests
  Stream<List<UserDataModel>> requestsInboxStream() {
    return userStream().map((user) => user.requestsInbox).asyncMap(_getUsersByIds);
  }

  Stream<List<UserDataModel>> requestsOutgoingStream() {
    return userStream().map((user) => user.requestsOutgoing).asyncMap(_getUsersByIds);
  }

  // Searches for users by field that are not already friends with the current user. Returns a list of users that begin with the search query
  Future<List<UserDataModel>> searchUsersByField(
      String field, String query) async {
    final currentUser = await _getUser();
    final users = await userCollection
        .where(field, isGreaterThanOrEqualTo: query)
        .where(field, isLessThan: '${query}z')
        .get();
    // print out user IDS
    final usersData =
        users.docs.map((user) => UserDataModel.fromMap(user.data())).toList();
    return usersData
        .where((user) => !currentUser.friends.contains(user.id))
        .toList();
  }

  // Searches for users by username that are not already friends with the current user. Returns a list of users that begin with the search query
  Future<List<UserDataModel>> searchUsers(String query) async {
    return searchUsersByField('displayName', query);
  }

  // Searches for users by email that are not already friends with the current user. Returns a list of users that begin with the search query
  Future<List<UserDataModel>> searchUsersByEmail(String query) async {
    return searchUsersByField('email', query);
  }
}

// Friend Data Model:
// {
// String id;
// String displayName;
// String email;
// String photoUrl;
// List<String> friends;
// List<String> requestsOutgoing;
// List<String> requestsInbox;
// List<CalendarEvents> availability;
// }