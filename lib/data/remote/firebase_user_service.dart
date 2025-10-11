import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> usersRef() =>
      _db.collection('users');

  Future<void> createOrUpdateUser(String uid, Map<String, dynamic> data) async {
    await usersRef().doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) =>
      usersRef().doc(uid).snapshots();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) =>
      usersRef().doc(uid).get();
}
