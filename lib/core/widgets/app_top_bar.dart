import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? avatarUrl;
  const AppTopBar({super.key, this.userName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.purple500,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'Olá',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Bem-vindo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'logout') Modular.to.navigate('/auth/login/');
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'profile', child: Text('Perfil')),
            const PopupMenuItem(value: 'logout', child: Text('Sair')),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
