import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  final Function(int) onPress;
  final int currentIndex;
  final bool isAdmin;

  const BottomNavigator({
    required this.currentIndex,
    required this.onPress,
    required this.isAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: true,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.blue,
      items: <BottomNavigationBarItem>[
        if (isAdmin)
          BottomNavigationBarItem(
            icon: const Icon(Icons.category_outlined, size: 40),
            activeIcon: const Icon(Icons.category),
            label: 'Fases',
          ),
        if (isAdmin)
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined, size: 40),
            activeIcon: const Icon(Icons.quiz),
            label: 'Exercícios',
          ),
        if (!isAdmin)
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/learn-off.png',
              height: 40,
            ),
            activeIcon: Image.asset(
              'assets/images/learn-on.png',
              height: 40,
            ),
            label: 'Fases',
          ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/person-off.png',
            height: 40,
          ),
          activeIcon: Image.asset(
            'assets/images/person-on.png',
            height: 40,
          ),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/shield-off.png',
            color: Colors.grey,
            height: 40,
          ),
          activeIcon: Image.asset(
            'assets/images/shield-on.png',
            height: 40,
          ),
          label: 'Leaderboard',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onPress,
    );
  }
}
