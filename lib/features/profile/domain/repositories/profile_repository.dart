import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> uploadProfilePicture(String uid, String imagePath);
  // O método signOut foi removido daqui
}
