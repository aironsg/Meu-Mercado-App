// lib/features/profile/domain/repositories/profile_repository.dart

import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<String> uploadProfilePicture(String uid, String imagePath);
}
