class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.pushToken,
    required this.email,
  });
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String pushToken;
  late String email;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['isOnline'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    pushToken = json['pushToken'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['name'] = name;
    _data['about'] = about;
    _data['created_at'] = createdAt;
    _data['isOnline'] = isOnline;
    _data['id'] = id;
    _data['last_active'] = lastActive;
    _data['pushToken'] = pushToken;
    _data['email'] = email;
    return _data;
  }
}
