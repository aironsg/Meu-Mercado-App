import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_mercado/features/items/domain/entities/item_entity.dart';
import '../../../../core/theme/app_colors.dart';
// 🚨 Reutiliza o AppBackground que agora contém o gradiente de contraste (laranja/amarelo)
import '../../../../core/widgets/app_background.dart';
import '../provider/home_page_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  // Widget auxiliar para construir a tabela de itens com limite de altura e rolagem interna
  Widget _buildItemListTable(BuildContext context, List<ItemEntity> items) {
    if (items.isEmpty)
      return const Center(child: Text('Nenhum item nesta lista.'));

    // Altura máxima para aproximadamente 5 linhas de dados (cerca de 250px)
    const double maxHeight = 250.0;

    // Cria todas as linhas de dados.
    final dataRows = items.map((item) {
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(item.name),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(item.quantity.toString()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'R\$ ${item.price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );
    }).toList();

    final allRows = [
      // Cabeçalho
      const TableRow(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: 4),
            child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: 4),
            child: Text('Qtd', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: 4),
            child: Text(
              'Preço Un.',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      ...dataRows,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: maxHeight, // Limita a visualização a cerca de 5 itens.
        ),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3.0),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.5),
            },
            children: allRows,
          ),
        ),
      ),
    );
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
        'icon': 'assets/icons/chart.png',
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
      // Fundo transparente para permitir que o gradiente do body apareça
      backgroundColor: Colors.transparent,
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
      // Envolve o conteúdo com o AppBackground (gradiente vibrante)
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                        // Cor de texto escura para contraste com o novo gradiente claro/vibrante.
                        style: TextStyle(
                          color: AppColors.textPrimaryLight.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        // Cor de texto escura
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
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

            // GRID DE CARDS
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                      color: AppColors.surface, // Mantém o card branco
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // VISÃO GERAL DA ÚLTIMA LISTA (PARTE INFERIOR)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Última Lista de Compras',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
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
                        ? (list['createdAt'] as DateTime).day
                                  .toString()
                                  .padLeft(2, '0') +
                              '/' +
                              (list['createdAt'] as DateTime).month
                                  .toString()
                                  .padLeft(2, '0')
                        : 'Data Indefinida';

                    final List<ItemEntity> items =
                        (list['items'] as List<dynamic>?)?.cast<ItemEntity>() ??
                        [];

                    return Card(
                      elevation: 4,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        title: Text('Lista de $date'),
                        subtitle: Text('$totalItems itens na lista.'),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Modular.to.pushNamed('/lists');
                          },
                          tooltip: 'Ver histórico completo',
                        ),
                        children: [
                          const Divider(height: 1),
                          _buildItemListTable(context, items),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextButton(
                                onPressed: () => Modular.to.pushNamed('/lists'),
                                child: const Text(
                                  'Ir para o Histórico de Compras',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Espaçamento final para a área de botões do sistema
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
