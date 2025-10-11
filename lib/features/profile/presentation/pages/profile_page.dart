import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // A variável user está correta, é usada apenas para obter o UID inicial
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // A chamada assíncrona com addPostFrameCallback está correta aqui
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Correto: Carrega o perfil assim que o widget estiver pronto
        ref.read(profileControllerProvider.notifier).loadProfile(user!.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final controller = ref.read(
      profileControllerProvider.notifier,
    ); // Obtém o controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.signOut(), // 💡 DELEGAÇÃO
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (profile) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => controller.updateProfilePicture(
                    profile.uid,
                  ), // Chamada correta
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profile.photoUrl != null
                        ? NetworkImage(profile.photoUrl!)
                        : null,
                    child: profile.photoUrl == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(profile.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => controller.signOut(), // 💡 DELEGAÇÃO
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair do aplicativo'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
