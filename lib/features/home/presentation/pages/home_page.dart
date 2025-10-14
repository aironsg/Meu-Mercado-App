import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../provider/home_page_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuário';

    // Monitora o provedor da última lista
    final latestListAsync = ref.watch(getLatestListProvider);

    // Estrutura de navegação Modular
    final tiles = [
      {
        'title': 'Perfil',
        'icon': 'assets/icons/profile.png',
        'route': () => Modular.to.pushNamed('/profile'),
      },
      {
        'title': 'Estatísticas', // Alterado de 'Histórico' para Estatísticas
        'icon': 'assets/icons/history.png',
        'route': () =>
            Modular.to.pushNamed('/history'), // Rota para nova HistoryPage
      },
      {
        'title': 'Cadastrar Lista', // Rota de Cadastro de Item/Lista
        'icon': 'assets/icons/add_item.png',
        'route': () => Modular.to.pushNamed('/item'),
      },
      {
        'title': 'Histórico', // Rota para Listagem de Listas (Tabela)
        'icon': 'assets/icons/list.png',
        'route': () => Modular.to.pushNamed('/lists'),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Mercado'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          // Lógica de Logout
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Modular.to.navigate('/login');
            },
            icon: const Icon(Icons.logout, size: 36),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SAUDAÇÃO (TOPO)
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_app_meu_mercado.png',
                  height: 100,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()},',
                        style: TextStyle(
                          color: AppColors.textPrimaryLight.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: user?.photoURL == null
                      ? Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // GRID DE CARDS (MAIOR PARTE DA TELA)
            Expanded(
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  return GestureDetector(
                    onTap: tile['route'] as void Function(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(tile['icon'] as String, height: 46),
                          const SizedBox(height: 10),
                          Text(
                            tile['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // VISÃO GERAL DA ÚLTIMA LISTA (PARTE INFERIOR)
            const Text(
              'Última Lista de Compras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            latestListAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Erro ao carregar lista: $e'),
              data: (list) {
                if (list == null) {
                  return const Text('Nenhuma lista cadastrada ainda.');
                }

                final totalItems =
                    (list['items'] as List<dynamic>?)?.length ?? 0;
                final date = list['createdAt'] is DateTime
                    ? (list['createdAt'] as DateTime).day.toString().padLeft(
                            2,
                            '0',
                          ) +
                          '/' +
                          (list['createdAt'] as DateTime).month
                              .toString()
                              .padLeft(2, '0')
                    : 'Data Indefinida';

                return Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    title: Text('Lista de $date'),
                    subtitle: Text('$totalItems itens na lista.'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Modular.to.navigate('/lists');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
