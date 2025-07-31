class User {
  final String id;
  final String username;
  final String email;
  final List<String> wishlist;

  User({
    required this.id, 
    required this.username, 
    required this.email,
    this.wishlist = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      wishlist: json['wishlist'] != null 
          ? (json['wishlist'] as List).map((item) => item.toString()).toList()
          : [],
    );
  }
}