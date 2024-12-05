import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<List<Map<String, dynamic>>> getUsersData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('usuario').get();

      final List<Map<String, dynamic>> users = [];

      const adminId = 't8aOO60dyqZQhIB2nEC9po5LBW32';

      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        final userId = doc.id;

        if (userId == adminId) {
          continue;
        }

        final usuarioFaseSnapshot = await FirebaseFirestore.instance
            .collection('usuario_fase')
            .where('id_usuario', isEqualTo: userId)
            .get();

        int totalXP = 0;
        int totalTempoDeEstudo = 0;
        int totalCoroas = 0;

        for (var faseDoc in usuarioFaseSnapshot.docs) {
          final faseData = faseDoc.data();
          totalXP += (faseData['pontos'] ?? 0) as int;
          totalTempoDeEstudo += (faseData['tempo_de_estudo'] ?? 0) as int;
          totalCoroas += (faseData['crown'] ?? 0) as int;
        }

        users.add({
          'id': userId,
          'nome': userData['nome'],
          'xp': totalXP,
          'foto': userData['foto_url'],
          'tempoDeEstudo': totalTempoDeEstudo,
          'totalCoroas': totalCoroas,
        });
      }

      users.sort((a, b) => b['xp'].compareTo(a['xp']));

      return users;
    } catch (e) {
      print('Erro ao buscar dados dos usuários: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getUsersData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar dados'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum usuário encontrado'));
        }

        final users = snapshot.data!;

        return Scaffold(
          body: ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              var userId = FirebaseAuth.instance.currentUser!.uid;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                horizontalTitleGap: 12,
                leading: _rank(index + 1),
                title: _avatarWithName(user['foto'], user['nome']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userId == 't8aOO60dyqZQhIB2nEC9po5LBW32')
                      _adminInfoButton(
                        context,
                        user['tempoDeEstudo'],
                        user['totalCoroas'],
                      ),
                    SizedBox(width: 10),
                    _xpAmount(user['xp']),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _adminInfoButton(
      BuildContext context, int? tempoDeEstudo, int? totalCoroas) {
    return IconButton(
      icon: const Icon(Icons.info, color: Colors.blue),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(15), // Define o padding
              title: const Text('Informações do Usuário'),
              content: IntrinsicHeight(
                // Ajusta o tamanho ao conteúdo
                child: IntrinsicWidth(
                  child: _adminInfo(tempoDeEstudo, totalCoroas),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _xpAmount(int xp) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Text(
        '$xp XP',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _avatarWithName(String? image, String? name) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _avatar(image),
          const SizedBox(width: 20),
          _friendName(name),
        ],
      ),
    );
  }

  Widget _friendName(String? name) {
    return Flexible(
      child: Text(
        name ?? 'Nome não disponível',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4B4B4B),
          fontSize: 18,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _avatar(String? image) {
    return CircleAvatar(
      backgroundImage: image != null ? AssetImage(image) : null,
      radius: 22,
      child: image == null ? const Icon(Icons.account_circle, size: 30) : null,
    );
  }

  Widget _rank(int rank) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF58CC02),
        ),
      ),
    );
  }

  Widget _adminInfo(int? tempoDeEstudo, int? totalCoroas) {
    String formattedTime = tempoDeEstudo != null
        ? formatTime(tempoDeEstudo)
        : 'Tempo não disponível';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Espaçamento uniforme
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(15), // Controla o espaçamento
          child: _iconWithText(
            icon: Icons.access_time,
            tooltip: 'Tempo de Estudo: $formattedTime',
            text: formattedTime,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15), // Controla o espaçamento
          child: _iconWithText(
            photo: 'assets/images/crown.png',
            tooltip: 'Total de Coroas: $totalCoroas',
            text: '$totalCoroas Coroas',
          ),
        ),
      ],
    );
  }

  Widget _iconWithText(
      {IconData? icon,
      String? photo,
      required String tooltip,
      required String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(
            icon,
            size: 30,
            color: Colors.black,
          )
        else
          Image.asset(
            photo!,
            width: 30,
            height: 30,
            color: Colors.amber,
          ),
        SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

String formatTime(int seconds) {
  if (seconds < 60) {
    return '$seconds segundos';
  } else if (seconds < 3600) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes minuto${minutes > 1 ? 's' : ''} e $remainingSeconds segundo${remainingSeconds > 1 ? 's' : ''}';
  } else if (seconds < 86400) {
    int hours = seconds ~/ 3600;
    int remainingMinutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$hours hora${hours > 1 ? 's' : ''}, $remainingMinutes minuto${remainingMinutes > 1 ? 's' : ''} e $remainingSeconds segundo${remainingSeconds > 1 ? 's' : ''}';
  } else {
    int days = seconds ~/ 86400;
    int remainingHours = (seconds % 86400) ~/ 3600;
    int remainingMinutes = (seconds % 3600) ~/ 60;
    return '$days dia${days > 1 ? 's' : ''}, $remainingHours hora${remainingHours > 1 ? 's' : ''} e $remainingMinutes minuto${remainingMinutes > 1 ? 's' : ''}';
  }
}
