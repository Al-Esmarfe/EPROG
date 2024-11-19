import 'package:flutter/material.dart';

class ExerciseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExerciseAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1.5,
      centerTitle: true,
      title: const Text(
        'CRUD de exercícios',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}
