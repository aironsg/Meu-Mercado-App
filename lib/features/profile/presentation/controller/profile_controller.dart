import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import para signOut
import 'package:flutter_modular/flutter_modular.dart'; // Import para navegação
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
    state = const AsyncValue.loading();
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
      await ref
          .read(profileRepositoryProvider)
          .uploadProfilePicture(uid, pickedFile.path);
      await loadProfile(uid);
    }
  }

  // 💡 Lógica de SignOut CENTRALIZADA e usando Modular
  Future<void> signOut() async {
    try {
      // 1. Executa o logout no Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Navega para a tela de Login usando o Modular
      Modular.to.navigate('/login');
    } catch (e) {
      // Aqui você poderia adicionar uma lógica para exibir uma mensagem de erro
      print('Erro ao tentar sair: $e');
    }
  }
}
