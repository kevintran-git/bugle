class Friend {
  final String id;
  final String name;
  final String profilePictureUrl;
  final String status;

  Friend({required this.id, required this.name, required this.profilePictureUrl, required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'status': status,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      profilePictureUrl: map['profilePictureUrl'],
      status: map['status'],
    );
  }
}