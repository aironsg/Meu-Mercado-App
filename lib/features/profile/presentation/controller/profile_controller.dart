// lib/features/profile/presentation/controller/profile_controller.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../data/repositories/profile_repository_provider.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile>>(
      (ref) => ProfileController(ref),
    );

class ProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  final Ref ref;
  ProfileController(this.ref) : super(const AsyncValue.loading());

  Future<void> loadProfile(String uid) async {
    // Mantemos o estado de erro/dados, mas forçamos o refresh da leitura
    state = state.when(
      data: (profile) => AsyncValue.data(profile),
      error: (e, s) => AsyncValue.error(e, s),
      loading: () => const AsyncValue.loading(),
    );
    try {
      final useCase = GetUserProfileUseCase(
        ref.read(profileRepositoryProvider),
      );
      final profile = await useCase.execute(uid);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfilePicture(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Pega o perfil atual para manter os dados existentes
      final currentProfile = state.asData?.value;
      if (currentProfile == null) return;

      try {
        // 1. Envia a imagem e recebe a nova URL
        final newPhotoUrl = await ref
            .read(profileRepositoryProvider)
            .uploadProfilePicture(uid, pickedFile.path);

        // 2. ✅ NOVO: Atualiza o estado imediatamente com a nova URL
        final updatedProfile = currentProfile.copyWith(photoUrl: newPhotoUrl);
        state = AsyncValue.data(updatedProfile);

        // 3. Recarrega o perfil do banco de dados para confirmar (opcional, mas seguro)
        await loadProfile(uid);
      } catch (e, st) {
        // Se a atualização falhar, reverte para o estado anterior e exibe erro
        state = AsyncValue.error(e, st);
        // Tenta recarregar o perfil original
        await loadProfile(uid);
      }
    }
  }

  // 💡 Lógica de SignOut CENTRALIZADA e usando Modular
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Modular.to.navigate('/login');
    } catch (e) {
      print('Erro ao tentar sair: $e');
    }
  }
}
