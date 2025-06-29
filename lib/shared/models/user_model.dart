class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> favoriteGenres;
  final int borrowedBooksCount;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.favoriteGenres = const [],
    this.borrowedBooksCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      borrowedBooksCount: map['borrowedBooksCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'favoriteGenres': favoriteGenres,
      'borrowedBooksCount': borrowedBooksCount,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? favoriteGenres,
    int? borrowedBooksCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      borrowedBooksCount: borrowedBooksCount ?? this.borrowedBooksCount,
    );
  }

  bool get isAdmin => role == 'admin';
}
