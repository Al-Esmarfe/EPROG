import 'package:flutter/material.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String nome;
  final String email;
  final String? fotoUrl;

  const AccountAppBar({
    super.key,
    required this.nome,
    required this.email,
    this.fotoUrl,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(100); // Aumenta a altura para melhor ajuste

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      backgroundColor: Colors.white,
      elevation: 1.5,
      leading: account(),
      leadingWidth: 500,
      centerTitle: false,
      actions: [
        avatar(),
      ],
    );
  }

  Widget avatar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: CircleAvatar(
        radius: 30,
        backgroundImage: fotoUrl != null
            ? AssetImage(fotoUrl!) as ImageProvider
            : AssetImage('assets/default_profile.png'),
        onBackgroundImageError: (_, __) {
          debugPrint("Erro ao carregar a imagem de perfil.");
        },
      ),
    );
  }

  Widget account() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nome,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B4B4B),
            ),
          ),
          Text(
            email,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFAFAFAF),
            ),
          ),
        ],
      ),
    );
  }
}
