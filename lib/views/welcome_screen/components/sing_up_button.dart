import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  String signUpMessage = '';

  Future<void> signUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Armazenar dados adicionais no Firestore para o usuário
      await FirebaseFirestore.instance
          .collection('usuario')
          .doc(userCredential.user?.uid)
          .set({
        'nome': usernameController.text,
        'data_de_criacao': DateTime.now(),
        'tipo_de_usuario': 'aluno',
        'foto_url': null,
      });

      // Criar as conquistas com current = 0
      List<Map<String, dynamic>> achievements = [
        {
          'name': 'Estudioso',
          'current': 0,
          'id_usuario': userCredential.user?.uid,
        },
        {
          'name': 'Mestre',
          'current': 0,
          'id_usuario': userCredential.user?.uid,
        },
        {
          'name': 'Rei',
          'current': 0,
          'id_usuario': userCredential.user?.uid,
        },
        {
          'name': 'Star',
          'current': 0,
          'id_usuario': userCredential.user?.uid,
        },
      ];

      // Adicionar as conquistas no Firestore
      for (var achievement in achievements) {
        await FirebaseFirestore.instance
            .collection('conquistas')
            .add(achievement);
      }

      // Vincular o usuário a todas as fases já existentes
      // 1. Obter todas as fases
      QuerySnapshot phasesSnapshot =
          await FirebaseFirestore.instance.collection('fase').get();

      // 2. Criar um documento na coleção 'usuario_fase' para cada fase
      for (var phaseDoc in phasesSnapshot.docs) {
        String usuarioFaseId = '${userCredential.user?.uid}_${phaseDoc.id}';

        await FirebaseFirestore.instance
            .collection('usuario_fase')
            .doc(usuarioFaseId)
            .set({
          'id_usuario': userCredential.user?.uid,
          'id_fase': phaseDoc.id,
          'crown': 0,
          'percent': 0,
          'pontos': 0,
          'tempo_de_estudo': 0,
        });
      }

      setState(() {
        signUpMessage = "Cadastro realizado com sucesso!";
      });

      Navigator.pushNamed(
          context, '/home'); // Navegar para a home após o cadastro
    } on FirebaseAuthException catch (e) {
      setState(() {
        signUpMessage = "Erro ao realizar cadastro: ${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Nome de Usuário"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: const Text("Cadastrar"),
            ),
            const SizedBox(height: 10),
            Text(
              signUpMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
