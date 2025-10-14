// lib/features/profile/data/profile_repository_impl.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    return UserProfile.fromMap(uid, doc.data()!);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  @override
  // ✅ ALTERADO: Retorna a URL como String
  Future<String> uploadProfilePicture(String uid, String imagePath) async {
    final ref = _storage.ref().child('profile_pictures/$uid.jpg');
    await ref.putFile(File(imagePath));
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({
      'photoUrl': downloadUrl,
    });

    await _auth.currentUser?.updatePhotoURL(downloadUrl);

    return downloadUrl; // ✅ Retorna a URL
  }
}
