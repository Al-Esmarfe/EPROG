import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const LeaderboardAppBar({super.key});

  @override
  _LeaderboardAppBarState createState() => _LeaderboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

class _LeaderboardAppBarState extends State<LeaderboardAppBar> {
  int? userRank;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchAppBarData();
  }

  Future<void> _fetchAppBarData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if the user is admin
      const adminId = 't8aOO60dyqZQhIB2nEC9po5LBW32';
      setState(() {
        isAdmin = user.uid == adminId;
      });

      // Fetch user rank if not admin
      if (!isAdmin) {
        final querySnapshot =
            await FirebaseFirestore.instance.collection('usuario').get();

        final List<Map<String, dynamic>> users = [];

        for (var doc in querySnapshot.docs) {
          final userId = doc.id;
          if (userId == adminId) continue;

          final usuarioFaseSnapshot = await FirebaseFirestore.instance
              .collection('usuario_fase')
              .where('id_usuario', isEqualTo: userId)
              .get();

          int totalXP = 0;
          for (var faseDoc in usuarioFaseSnapshot.docs) {
            totalXP += (faseDoc.data()['pontos'] ?? 0) as int;
          }

          users.add({'id': userId, 'xp': totalXP});
        }

        users.sort((a, b) => b['xp'].compareTo(a['xp']));

        final userRankIndex = users.indexWhere((u) => u['id'] == user.uid);

        setState(() {
          userRank = userRankIndex + 1; // Rank is 1-based
        });
      }
    } catch (e) {
      print('Erro ao buscar dados do AppBar: $e');
    }
  }

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
          isAdmin
              ? const Text(
                  'Board dos Líderes',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  userRank != null
                      ? 'Você está na $userRankª posição!'
                      : 'Carregando sua posição...',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }
}
