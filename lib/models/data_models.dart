class UserDataModel {
  UserDataModel({
    required this.id,
    required this.displayName,
    this.email,
    this.profilePictureUrl,
    required this.friends,
    required this.requestsInbox,
    required this.requestsOutgoing,
    required this.availability,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? profilePictureUrl;
  final List<String> friends;
  final List<String> requestsInbox;
  final List<String> requestsOutgoing;
  final List<CalendarEvents> availability;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'friends': friends,
      'requestsInbox': requestsInbox,
      'requestsOutgoing': requestsOutgoing,
      'availability': availability.map((event) => event.toMap()).toList(),
    };
  }

  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
      id: map['id'],
      displayName: map['displayName'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'],
      friends: List<String>.from(map['friends']),
      requestsInbox: List<String>.from(map['requestsInbox']),
      requestsOutgoing: List<String>.from(map['requestsOutgoing']),
      availability: List<CalendarEvents>.from(
        map['availability'].map(
              (event) => CalendarEvents.fromMap(event),
        ),
      ),
    );
  }
}

class CalendarEvents {
  CalendarEvents({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
  });

  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String description;

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'description': description,
    };
  }

  factory CalendarEvents.fromMap(Map<String, dynamic> map) {
    return CalendarEvents(
      startTime: map['startTime'].toDate(),
      endTime: map['endTime'].toDate(),
      title: map['title'],
      description: map['description'],
    );
  }
}
