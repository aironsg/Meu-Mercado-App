import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String _collectionPath = 'shopping_lists';

  /// Salva o payload completo da lista de compras (data, userId e itens) no Firestore.
  @override
  Future<void> saveList(Map<String, dynamic> shoppingList) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'Usuário não autenticado. Não é possível salvar a lista.',
      );
    }

    try {
      // Adiciona o documento contendo todos os dados (incluindo o array de itens)
      await _firestore.collection(_collectionPath).add({
        ...shoppingList,
        'userId': uid,
        'createdAt':
            FieldValue.serverTimestamp(), // Marca a data/hora exata do cadastro
      });
    } catch (e) {
      throw Exception('Falha ao salvar a lista de compras no servidor.');
    }
  }

  /// Busca itens de uma categoria específica na última lista cadastrada pelo usuário.
  /// (Simula a busca da lista "do mês anterior").
  @override
  Future<List<ItemEntity>> getPreviousListItemsByCategory(
    String category,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return [];
    }

    try {
      // 1. Busca a lista mais recente do usuário (limitamos a 1, pois queremos a "anterior")
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(1) // Pega apenas a última lista
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Nenhuma lista encontrada
      }

      // 2. Extrai os dados
      final listData = querySnapshot.docs.first.data();
      final itemsMap = listData['items'] as List<dynamic>?;

      if (itemsMap == null) {
        return [];
      }

      // 3. Converte os mapas em ItemEntity e filtra pela categoria
      return itemsMap
          .map((itemMap) => ItemEntity.fromMap(itemMap as Map<String, dynamic>))
          .where((item) => item.category == category)
          .toList();
    } catch (e) {
      // Em caso de falha na busca, retornamos uma lista vazia para não quebrar o app.
      return [];
    }
  }
}
