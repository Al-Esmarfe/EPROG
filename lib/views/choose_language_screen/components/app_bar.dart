import 'package:tcc_projeto/views/choose_language_screen/components/stage_progress_bar.dart';
import 'package:flutter/material.dart';

class ChooseLanguageAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChooseLanguageAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      title: const StageProgressBar(0.5),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFAFAFAF),
            size: 32,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
