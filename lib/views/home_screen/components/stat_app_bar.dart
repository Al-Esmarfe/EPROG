import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatAppBar extends StatefulWidget implements PreferredSizeWidget {
  const StatAppBar({super.key});

  @override
  _StatAppBarState createState() => _StatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class _StatAppBarState extends State<StatAppBar> {
  int totalCoroas = 0; // Variável para armazenar o total de coroas
  bool isLoading = true; // Indicador de carregamento
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchTotalCoroas();
  }

  // Método para buscar as coroas do banco de dados
  Future<void> fetchTotalCoroas() async {
    try {
      final user = _auth.currentUser; // Aqui você pega o id do usuário logado

      if (user == null) {
        setState(() {
          isLoading =
              false; // Finaliza o carregamento, caso o usuário não esteja logado
        });
        return;
      }

      // Query para buscar todas as fases do usuário na coleção 'usuario_fase'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuario_fase')
          .where('id_usuario',
              isEqualTo: user.uid) // Usa user.uid para comparação
          .get();

      int sumCoroas = 0;

      // Soma todas as coroas de cada fase
      for (var doc in snapshot.docs) {
        sumCoroas += (doc['crown'] ?? 0) as int; // Adiciona o valor das coroas
      }

      // Atualiza o estado com o total de coroas
      setState(() {
        totalCoroas = sumCoroas;
        isLoading = false; // Finaliza o carregamento
      });
    } catch (e) {
      print('Erro ao buscar coroas: $e');
      setState(() {
        isLoading = false; // Finaliza o carregamento, mesmo com erro
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      backgroundColor: Colors.white,
      elevation: 1.5,
      leading: flag(),
      actions: [
        crown(totalCoroas),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget heart() {
    return Row(
      children: [
        Image.asset('assets/images/heart.png', width: 36),
        const SizedBox(width: 2),
        Image.asset('assets/images/infinity.png', width: 20),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget streak(int n) {
    return Row(
      children: [
        Image.asset('assets/images/streak.png', width: 24),
        const SizedBox(width: 4),
        Text(
          '$n',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9600),
          ),
        ),
      ],
    );
  }

  Widget crown(int n) {
    return Row(
      children: [
        Image.asset('assets/images/crown.png', width: 30),
        const SizedBox(width: 4),
        isLoading
            ? const CircularProgressIndicator() // Exibe carregamento se estiver buscando os dados
            : Text(
                '$n', // Exibe o número de coroas
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC800),
                ),
              ),
      ],
    );
  }

  Widget flag() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 18, bottom: 18),
      decoration: BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.scaleDown,
          image: AssetImage('assets/images/logo-c.png'),
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 2.5,
          color: const Color(0xFFE5E5E5),
        ),
        color: Colors.grey.shade100,
      ),
    );
  }
}
