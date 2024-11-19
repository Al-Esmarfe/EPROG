import 'package:flutter/material.dart';
import 'package:tcc_projeto/views/profile_screen/components/edit_profile_screen.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF2B70C9), size: 24),
            tooltip: 'Voltar',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8), // Espaçamento entre a seta e o texto
          Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Sair',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF2B70C9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      toolbarHeight: 90,
      backgroundColor: Colors.white,
      elevation: 1.5,
      centerTitle: true,
      title: const Text(
        'Perfil',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF2B70C9), size: 30),
          tooltip: 'Editar Perfil',
          onPressed: () {
            // Navegar para a tela de edição
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          },
        ),
      ],
    );
  }
}
