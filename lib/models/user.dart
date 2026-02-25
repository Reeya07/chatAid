class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({required this.uid, required this.email, required this.name});

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final email = (data['email'] ?? '').toString();
    final name = (data['name'] ?? '').toString();
    return AppUser(uid: uid, email: email, name: name);
  }

  Map<String, dynamic> toMap() => {'email': email, 'name': name};
}
