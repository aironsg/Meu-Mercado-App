// lib/features/profile/domain/entities/user_profile.dart

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'photoUrl': photoUrl};
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
