// lib/features/items/data/repositories/item_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/item_entity.dart';
import '../../data/models/item_model.dart';
import '../../domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionPath = 'shopping_lists';

  @override
  Future<void> saveList(Map<String, dynamic> shoppingList) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'Usuário não autenticado. Não é possível salvar a lista.',
      );
    }

    try {
      await _firestore.collection(_collectionPath).add({
        ...shoppingList,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Falha ao salvar a lista de compras no servidor. $e');
    }
  }

  @override
  Future<List<ItemEntity>> getPreviousListItemsByCategory(
    String category,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final listData = querySnapshot.docs.first.data();
      final itemsMap = listData['items'] as List<dynamic>?;

      if (itemsMap == null) return [];

      final items = itemsMap
          .map((i) => ItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .where((item) => item.category == category)
          .toList();

      return items;
    } catch (e) {
      // não propagar exceção fatal — retorna lista vazia e deixe UI lidar com isso
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserLists() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      final lists = querySnapshot.docs.map((doc) {
        final data = doc.data();

        // createdAt pode ser Timestamp ou String; normalize para DateTime
        DateTime? createdAt;
        final rawCreated = data['createdAt'];
        if (rawCreated is Timestamp) {
          createdAt = rawCreated.toDate();
        } else if (rawCreated is String) {
          createdAt = DateTime.tryParse(rawCreated);
        } else {
          createdAt = null;
        }

        final itemsRaw = data['items'] as List<dynamic>? ?? [];
        final items = itemsRaw
            .map((i) => ItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList();

        return <String, dynamic>{
          'id': doc.id,
          'createdAt': createdAt,
          'items': items, // List<ItemModel> (subtipo de ItemEntity)
        };
      }).toList();

      return lists;
    } catch (e) {
      throw Exception('Erro ao buscar listas: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getLatestList() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();

      DateTime? createdAt;
      final rawCreated = data['createdAt'];
      if (rawCreated is Timestamp) {
        createdAt = rawCreated.toDate();
      } else if (rawCreated is String) {
        createdAt = DateTime.tryParse(rawCreated);
      } else {
        createdAt = null;
      }

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .map((i) => ItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();

      return {
        'id': doc.id,
        'createdAt': createdAt,
        'items': items, // List<ItemModel>
      };
    } catch (e) {
      throw Exception('Erro ao buscar a lista mais recente: $e');
    }
  }

  @override
  // 🚨 NOVO: Implementação unificada para adicionar OU editar item
  Future<void> saveItemInList(String listId, ItemEntity itemToSave) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    try {
      final listRef = _firestore.collection(_collectionPath).doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) throw Exception('Lista não encontrada.');

      final data = snapshot.data();
      if (data == null) throw Exception('Dados inválidos.');

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final List<ItemModel> items = itemsRaw
          .map((i) => ItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();

      final index = items.indexWhere((i) => i.id == itemToSave.id);

      if (index != -1) {
        // Atualizar item existente
        items[index] = ItemModel.fromMap(itemToSave.toMap());
      } else {
        // Adicionar novo item
        items.add(ItemModel.fromMap(itemToSave.toMap()));
      }

      await listRef.update({
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  // Mantém o método antigo, agora reusando a nova lógica de salvar
  Future<void> updateItemInList(String listId, ItemEntity updatedItem) async {
    return saveItemInList(listId, updatedItem);
  }

  @override
  // 🚨 NOVO: Remove um item de uma lista existente
  Future<void> removeItemFromList(String listId, String itemId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    try {
      final listRef = _firestore.collection(_collectionPath).doc(listId);
      final snapshot = await listRef.get();

      if (!snapshot.exists) throw Exception('Lista não encontrada.');

      final data = snapshot.data();
      if (data == null) throw Exception('Dados inválidos.');

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final List<ItemModel> items = itemsRaw
          .map((i) => ItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();

      items.removeWhere((item) => item.id == itemId);

      await listRef.update({
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  // 🚨 NOVO: Remove uma lista completa
  Future<void> deleteList(String listId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    try {
      await _firestore.collection(_collectionPath).doc(listId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar lista: $e');
    }
  }
}
