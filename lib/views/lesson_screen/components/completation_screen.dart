import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompletionScreen extends StatelessWidget {
  final String idFase;
  final String idUsuario;
  final int pontos;
  final int tempoDeEstudo;

  const CompletionScreen({
    super.key,
    required this.idFase,
    required this.idUsuario,
    required this.pontos,
    required this.tempoDeEstudo,
  });

  Future<Map<String, dynamic>> _fetchPhaseData() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario_fase')
          .doc('${idUsuario}_$idFase');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() ?? {};
        data['percent'] = (data['percent'] ?? 0.0).toDouble();
        return data;
      }
    } catch (e) {
      print('Erro ao buscar dados da fase: $e');
    }
    return {};
  }

  Future<void> _updateUserPhaseData(BuildContext context) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('usuario_fase')
          .doc('${idUsuario}_$idFase');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        int currentTempoDeEstudo = docSnapshot.data()?['tempo_de_estudo'] ?? 0;
        int currentPontos = docSnapshot.data()?['pontos'] ?? 0;
        double currentPercent =
            (docSnapshot.data()?['percent'] ?? 0.0).toDouble();
        int currentCrown = docSnapshot.data()?['crown'] ?? 0;

        double newPercent = currentPercent + 0.20;
        bool achievedCrown = false;

        if (newPercent >= 1.0) {
          newPercent = 0.0;
          currentCrown += 1;
          achievedCrown = true;
        }

        await docRef.update({
          'pontos': currentPontos + pontos,
          'tempo_de_estudo': currentTempoDeEstudo + tempoDeEstudo,
          'percent': newPercent.clamp(0.0, 1.0),
          'crown': currentCrown,
        });

        if (achievedCrown) {
          _showCrownAchievement(context);
        }
      }
    } catch (e) {
      print('Erro ao atualizar usuario_fase: $e');
    }
  }

  void _showCrownAchievement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conquista!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
                'assets/images/crown.png'), // Adicione a imagem da coroa nos assets
            const SizedBox(height: 10),
            const Text(
              '+1 Coroa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateUserPhaseData(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fase Concluída!'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPhaseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          double currentPercent = (data['percent'] ?? 0.0).toDouble();
          int timesRemaining = (5 - (currentPercent / 0.20).ceil()).clamp(0, 5);

          print('timesRemaining: ${timesRemaining - 1} -- $timesRemaining');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Parabéns!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pontuação final: $pontos',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Tempo gasto: ${tempoDeEstudo}s',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                if (timesRemaining > 0)
                  if (timesRemaining - 1 == 0)
                    Text(
                      'Você ganhou uma estrelha',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  else
                    Text(
                      'Faltam $timesRemaining vezes para ganhar uma coroa.',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/crown.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '+1',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Voltar ao Início'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
