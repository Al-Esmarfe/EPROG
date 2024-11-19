import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final user = _auth.currentUser;

class LeaderboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int? userRank;
  final bool isAdminId;

  const LeaderboardAppBar({
    super.key,
    required this.userRank,
    required this.isAdminId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 2.0,
      title: Column(
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          isAdminId
              ? const Text(
                  'Board dos Líderes',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                )
              : Text(
                  'Você está na $userRankª posição!',
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                )
        ],
      ),
    );
  }
}
