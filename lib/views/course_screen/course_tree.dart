import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/course_node.dart';

class CourseTree extends StatelessWidget {
  const CourseTree({super.key});

  Stream<List<Map<String, dynamic>>> getFasesForUser() async* {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      yield [];
      return;
    }

    try {
      // Obtém todos os documentos de fase vinculados ao usuário
      final fasesIds = await FirebaseFirestore.instance
          .collection('fase')
          .get()
          .then((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

      final List<Map<String, dynamic>> fases = [];
      final Map<String, Map<String, dynamic>> usuarioFaseData = {};

      for (String idFase in fasesIds) {
        // Constrói o ID do documento no formato idUsuario_idFase
        final docId = "${user.uid}_$idFase";

        // Tenta buscar o documento específico na coleção usuario_fase
        final usuarioFaseDoc = await FirebaseFirestore.instance
            .collection('usuario_fase')
            .doc(docId)
            .get();

        if (usuarioFaseDoc.exists) {
          final data = usuarioFaseDoc.data();
          usuarioFaseData[idFase] = {
            'crown': data?['crown'],
            'prioridade': data?['prioridade'],
            'percent': data?['percent'],
          };

          // Agora, busca a fase em si usando o ID da fase
          final faseDoc = await FirebaseFirestore.instance
              .collection('fase')
              .doc(idFase)
              .get();

          if (faseDoc.exists) {
            var faseData = faseDoc.data();
            faseData?['id'] = idFase;

            // Adiciona as informações crown, prioridade e percent do usuario_fase
            faseData?['crown'] = usuarioFaseData[idFase]?['crown'];
            faseData?['percent'] = usuarioFaseData[idFase]?['percent'];

            fases.add(faseData!);
          }
        }
      }

      fases.sort(
          (a, b) => (a['prioridade'] ?? 0) > (b['prioridade'] ?? 0) ? 1 : -1);

      yield fases;
    } catch (error) {
      print("Erro ao buscar dados do Firestore: $error");
      yield [];
    }
  }

  Color _parseColor(String? colorString) {
    // Verificar se a string tem 6 caracteres (RRGGBB) e adicionar 'FF' no início
    if (colorString != null && colorString.length == 6) {
      colorString = 'FF$colorString'; // Adiciona a opacidade completa
    }

    // Agora, verifica se a string tem 8 caracteres (AARRGGBB)
    if (colorString != null && colorString.length == 8) {
      try {
        // Converte a string hex para a cor no formato correto
        return Color(int.parse(colorString, radix: 16));
      } catch (e) {
        print('Erro ao converter cor: $e');
      }
    }

    // Retorna uma cor padrão caso a conversão falhe
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getFasesForUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar as fases'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma fase encontrada'));
        }

        final fases = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              for (var fase in fases) ...[
                CourseNode(
                  fase['nome'],
                  idFase: fase['id'],
                  idUsuario: user?.uid ?? '',
                  image: fase['imagem'],
                  color: _parseColor(fase['cor']),
                  crown: fase['crown'],
                  percent: fase['percent'],
                ),
                const SizedBox(height: 10),
              ]
            ],
          ),
        );
      },
    );
  }
}
