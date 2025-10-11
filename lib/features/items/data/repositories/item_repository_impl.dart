import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addItem(ItemEntity item) async {
    await _firestore
        .collection('users')
        .doc(item.id)
        .collection('items')
        .doc(item.id)
        .set(
          ItemModel(
            id: item.id,
            name: item.name,
            category: item.category,
            quantity: item.quantity,
            price: item.price,
            note: item.note,
          ).toMap(),
        );
  }

  @override
  Future<List<ItemEntity>> getItems(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .get();

    return snapshot.docs.map((doc) => ItemModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> deleteItem(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}
