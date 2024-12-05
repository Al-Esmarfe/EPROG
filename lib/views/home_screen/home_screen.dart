import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcc_projeto/views/course_screen/course_tree.dart';
import 'package:tcc_projeto/views/explore_screen/components/exercise_crud.dart';
import 'package:tcc_projeto/views/explore_screen/components/phase_crud.dart';
import 'package:tcc_projeto/views/explore_screen/explore_screen.dart';
import 'package:tcc_projeto/views/home_screen/components/bottom_navigator.dart';
import 'package:tcc_projeto/views/home_screen/components/exercise_app_bar.dart';
import 'package:tcc_projeto/views/home_screen/components/phase_app_bar.dart';
import 'package:tcc_projeto/views/leaderboard_screen/leaderboard_screen.dart';
import 'package:tcc_projeto/views/profile_screen/profile_admin_screen.dart';
import 'package:tcc_projeto/views/profile_screen/profile_screen.dart';
import 'package:tcc_projeto/views/home_screen/components/stat_app_bar.dart';
import 'package:tcc_projeto/views/home_screen/components/profile_app_bar.dart';
import 'package:tcc_projeto/views/home_screen/components/leaderboard_app_bar.dart';
import 'package:tcc_projeto/views/home_screen/components/explore_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool isAdmin = false;
  int? userRank; // Para armazenar o rank do usuário

  @override
  void initState() {
    super.initState();
    _fetchUserType();
    _fetchUserRank(); // Chama para calcular o rank do usuário
  }

  // Função para buscar o tipo de usuário
  Future<void> _fetchUserType() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuario')
          .doc(userId)
          .get();
      final tipoDeUsuario = userDoc['tipo_de_usuario'];
      setState(() {
        isAdmin = tipoDeUsuario == 'administrador';
      });
    }
  }

  // Função para calcular o rank do usuário
  Future<void> _fetchUserRank() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('usuario').get();

      const adminId = 't8aOO60dyqZQhIB2nEC9po5LBW32';

      final List<Map<String, dynamic>> users = [];
      for (var doc in querySnapshot.docs) {
        final userId = doc.id;

        // Ignora o usuário se for o administrador
        if (userId == adminId) {
          continue; // Pula o administrador
        }

        // Obtém as informações de xp, tempo de estudo e coroas a partir da coleção usuario_fase
        final usuarioFaseSnapshot = await FirebaseFirestore.instance
            .collection('usuario_fase')
            .where('id_usuario', isEqualTo: userId)
            .get();

        int totalXP = 0;

        // Soma os valores de xp, tempo_de_estudo e coroas para o usuário
        for (var faseDoc in usuarioFaseSnapshot.docs) {
          final faseData = faseDoc.data();
          totalXP += (faseData['pontos'] ?? 0) as int;
        }

        users.add({
          'id': userId,
          'xp': totalXP,
        });
      }

      // Ordena os usuários por XP (em ordem decrescente)
      users.sort((a, b) => b['xp'].compareTo(a['xp']));

      // Encontra a posição do usuário
      final userIndex = users.indexWhere((user) => user['id'] == userId);
      setState(() {
        userRank = userIndex != -1 ? userIndex + 1 : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      if (isAdmin) const PhaseCrud() else const CourseTree(),
      if (isAdmin) const ExerciseCrud(),
      if (isAdmin) const AdminProfileScreen() else const ProfileScreen(),
      const LeaderboardScreen(),
    ];

    final List<PreferredSizeWidget> appBars = [
      if (isAdmin) const PhaseAppBar() else const StatAppBar(),
      if (isAdmin) const ExerciseAppBar(),
      const ProfileAppBar(),
      LeaderboardAppBar(),
    ];

    return Scaffold(
      appBar: appBars[currentIndex],
      bottomNavigationBar: BottomNavigator(
        currentIndex: currentIndex,
        onPress: onBottomNavigatorTapped,
        isAdmin: isAdmin,
      ),
      body: screens[currentIndex],
    );
  }

  void onBottomNavigatorTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
