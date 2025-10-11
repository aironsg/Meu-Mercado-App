import 'package:flutter/foundation.dart';

class ListState {
  final List<Map<String, dynamic>>
  lists; // Lista de Maps (onde cada Map é uma lista de compras)
  final bool loading;
  final String? error;

  ListState({this.lists = const [], this.loading = false, this.error});

  ListState copyWith({
    List<Map<String, dynamic>>? lists,
    bool? loading,
    String? error,
  }) {
    return ListState(
      lists: lists ?? this.lists,
      loading: loading ?? this.loading,
      error: error, // Limpa o erro se não for explicitamente fornecido
    );
  }
}
