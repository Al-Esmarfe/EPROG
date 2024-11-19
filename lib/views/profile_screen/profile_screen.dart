import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcc_projeto/views/profile_screen/components/achievements.dart';
import 'components/account_app_bar.dart';
import 'components/statistics.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;
  int totalCoroas = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUsuarioFaseData(String userId) async {
    try {
      final QuerySnapshot userFaseDocs = await _firestore
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: userId)
          .get();

      int totalPontos = 0;
      int totalTempoEstudo = 0;

      for (var doc in userFaseDocs.docs) {
        totalPontos += (doc['pontos'] ?? 0) as int;
        totalTempoEstudo += (doc['tempo_de_estudo'] ?? 0) as int;
      }

      setState(() {
        userData?['totalPontos'] = totalPontos;
        userData?['totalTempoEstudo'] = totalTempoEstudo;
      });
    } catch (e) {
      print("Erro ao buscar dados de usuario_fase: $e");
    }
  }

  Future<void> fetchTotalCoroas(String userId) async {
    try {
      final QuerySnapshot userFaseDocs = await _firestore
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: userId)
          .get();

      int sumCoroas = 0;

      for (var doc in userFaseDocs.docs) {
        sumCoroas += (doc['crown'] ?? 0) as int;
      }

      setState(() {
        totalCoroas = sumCoroas;
      });
    } catch (e) {
      print('Erro ao buscar coroas: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('usuario').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });

          await fetchUsuarioFaseData(user.uid);

          await fetchTotalCoroas(user.uid);
        }
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AccountAppBar(
        nome: userData?['nome'] ?? 'Usuário',
        email: _auth.currentUser?.email ?? 'email@example.com',
        fotoUrl: userData?['foto_url'],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Statistics(
                      totalPontos: userData?['totalPontos'] ?? 0,
                      totalTempoEstudo: userData?['totalTempoEstudo'] ?? 0,
                      totalCoroas: totalCoroas,
                    ),
                    Achievements(userId: _auth.currentUser?.uid ?? ''),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
