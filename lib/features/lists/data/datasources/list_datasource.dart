import '../../../items/domain/entities/item_entity.dart';
import '../../domain/entities/shopping_list_entity.dart';
// ✅ Implementação usando Firestore (pode adaptar para local)
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ListDataSource {
  Future<List<ShoppingListEntity>> getAllLists();
  Future<ShoppingListEntity?> getLatestList();
  Future<void> createList(ShoppingListEntity list);
}

class ListDataSourceImpl implements ListDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> createList(ShoppingListEntity list) async {
    await firestore.collection('shopping_lists').doc(list.id).set({
      'id': list.id,
      'name': list.name,
      'category': list.category,
      'createdAt': list.createdAt.toIso8601String(),
      'items': list.items
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'category': e.category,
              'quantity': e.quantity,
              'price': e.price,
              'note': e.note,
            },
          )
          .toList(),
    });
  }

  @override
  Future<List<ShoppingListEntity>> getAllLists() async {
    final query = await firestore
        .collection('shopping_lists')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return ShoppingListEntity(
        id: data['id'],
        name: data['name'],
        category: data['category'],
        createdAt: DateTime.parse(data['createdAt']),
        items: (data['items'] as List).map((e) {
          return ItemEntity(
            id: e['id'],
            name: e['name'],
            category: e['category'],
            quantity: e['quantity'],
            price: (e['price'] as num).toDouble(),
            note: e['note'],
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<ShoppingListEntity?> getLatestList() async {
    final query = await firestore
        .collection('shopping_lists')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();

    return ShoppingListEntity(
      id: data['id'],
      name: data['name'],
      category: data['category'],
      createdAt: DateTime.parse(data['createdAt']),
      items: (data['items'] as List).map((e) {
        return ItemEntity(
          id: e['id'],
          name: e['name'],
          category: e['category'],
          quantity: e['quantity'],
          price: (e['price'] as num).toDouble(),
          note: e['note'],
        );
      }).toList(),
    );
  }
}
