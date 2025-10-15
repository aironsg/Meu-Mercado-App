// lib/utils/test_data_initializer.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class TestDataInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'shopping_lists';

  Future<void> initializeMockData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint(
        'TEST DATA INITIALIZER: Usuário não autenticado. Não é possível inicializar dados.',
      );
      return;
    }

    final uid = user.uid;

    // --- 1. Definir Dados Mock ---

    // Define as datas mock (Outubro e Setembro)
    final DateTime october = DateTime.now().subtract(const Duration(days: 15));
    final DateTime september = october.subtract(const Duration(days: 30));

    // Itens para Outubro (O)
    final ItemEntity itemO1 = ItemEntity(
      id: 'o_id1',
      name: 'Arroz',
      category: 'MERCADO',
      quantity: 2,
      price: 16.50,
    );
    final ItemEntity itemO2 = ItemEntity(
      id: 'o_id2',
      name: 'Banana',
      category: 'FEIRA',
      quantity: 5,
      price: 4.50,
    );
    final ItemEntity itemO3 = ItemEntity(
      id: 'o_id3',
      name: 'Sabão em Pó',
      category: 'CASA',
      quantity: 1,
      price: 12.00,
    );

    // Itens para Setembro (S)
    final ItemEntity itemS1 = ItemEntity(
      id: 's_id1',
      name: 'Arroz',
      category: 'MERCADO',
      quantity: 2,
      price: 15.00,
    );
    final ItemEntity itemS2 = ItemEntity(
      id: 's_id2',
      name: 'Banana',
      category: 'FEIRA',
      quantity: 5,
      price: 5.00,
    );
    final ItemEntity itemS3 = ItemEntity(
      id: 's_id3',
      name: 'Frango',
      category: 'MERCADO',
      quantity: 3,
      price: 18.00,
    );

    final listOctober = {
      'id': 'mock_october_list_${uid}', // ID ÚNICO POR USUÁRIO
      'userId': uid,
      'createdAt': Timestamp.fromDate(october),
      'items': [itemO1.toMap(), itemO2.toMap(), itemO3.toMap()],
    };

    final listSeptember = {
      'id': 'mock_september_list_${uid}', // ID ÚNICO POR USUÁRIO
      'userId': uid,
      'createdAt': Timestamp.fromDate(september),
      'items': [itemS1.toMap(), itemS2.toMap(), itemS3.toMap()],
    };

    final listsToInsert = [listOctober, listSeptember];

    // --- 2. Checagem e Inserção no Firestore ---

    // Checa se a lista de Outubro já existe para ESTE USUÁRIO
    final existingDoc = await _firestore
        .collection(_collectionPath)
        .doc(listOctober['id'] as String)
        .get();

    if (existingDoc.exists) {
      debugPrint(
        'TEST DATA INITIALIZER: Dados de teste para UID $uid já existem. Pulando.',
      );
      return;
    }

    debugPrint(
      'TEST DATA INITIALIZER: Inserindo dados de teste no Firestore para UID $uid...',
    );

    try {
      final batch = _firestore.batch();
      for (var list in listsToInsert) {
        final docRef = _firestore
            .collection(_collectionPath)
            .doc(list['id'] as String);
        batch.set(docRef, list);
      }
      await batch.commit();
      debugPrint(
        'TEST DATA INITIALIZER: Inicialização de dados de teste concluída!',
      );
    } catch (e) {
      debugPrint('TEST DATA INITIALIZER ERROR: Falha ao inserir dados: $e');
      rethrow;
    }
  }
}
