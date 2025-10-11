class RecoverState {
  final bool loading;
  final String? message;
  final String? error;

  RecoverState({this.loading = false, this.message, this.error});

  RecoverState copyWith({bool? loading, String? message, String? error}) {
    return RecoverState(
      loading: loading ?? this.loading,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }
}
