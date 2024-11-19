import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Achievements extends StatefulWidget {
  final String userId;

  const Achievements({super.key, required this.userId});

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  List<Map<String, dynamic>> achievementsList = [];

  @override
  void initState() {
    super.initState();
    fetchUserProgress();
  }

  Future<void> fetchUserProgress() async {
    try {
      final QuerySnapshot userAchievementsDocs = await FirebaseFirestore
          .instance
          .collection('conquistas')
          .where('id_usuario', isEqualTo: widget.userId)
          .get();

      achievementsList = mockAchievements;

      for (var doc in userAchievementsDocs.docs) {
        Map<String, dynamic> userAchievement =
            doc.data() as Map<String, dynamic>;

        for (var achievement in achievementsList) {
          if (userAchievement['name'] == achievement['label']) {
            achievement['current'] = userAchievement['current'] ?? 0;
            break;
          }
        }
      }

      await updateScholarAchievement();
      await updateMasterAchievement();
      await updateKingAchievement();
      await updateStarAchievement();

      setState(() {});
    } catch (e) {
      print('Erro ao buscar conquistas: $e');
    }
  }

  Future<void> updateStarAchievement() async {
    try {
      final QuerySnapshot userPhasesDocs = await FirebaseFirestore.instance
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: widget.userId)
          .get();

      int phasesWithFiveCrowns = userPhasesDocs.docs.fold(0, (count, doc) {
        return (doc['crown'] ?? 0) == 5 ? count + 1 : count;
      });

      for (var achievement in achievementsList) {
        if (achievement['label'] == 'Star') {
          if (achievement['current'] < achievement['target']) {
            achievement['current'] =
                phasesWithFiveCrowns >= achievement['target']
                    ? achievement['target']
                    : phasesWithFiveCrowns;
          }
          break;
        }
      }

      setState(() {});
    } catch (e) {
      print('Erro ao atualizar a conquista Star: $e');
    }
  }

  Future<void> updateKingAchievement() async {
    try {
      final QuerySnapshot userPhasesDocs = await FirebaseFirestore.instance
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: widget.userId)
          .get();

      int totalCrowns = userPhasesDocs.docs.fold(0, (sum, doc) {
        return sum + ((doc['crown'] ?? 0) as int);
      });

      for (var achievement in achievementsList) {
        if (achievement['label'] == 'Rei') {
          if (achievement['current'] < achievement['target']) {
            achievement['current'] =
                totalCrowns.clamp(0, achievement['target']);
          }
          break;
        }
      }

      setState(() {});
    } catch (e) {
      print('Erro ao atualizar a conquista Rei: $e');
    }
  }

  Future<void> updateMasterAchievement() async {
    try {
      final QuerySnapshot userPhasesDocs = await FirebaseFirestore.instance
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: widget.userId)
          .get();

      int totalXp = userPhasesDocs.docs.fold(0, (sum, doc) {
        return sum + ((doc['pontos'] ?? 0) as int);
      });

      for (var achievement in achievementsList) {
        if (achievement['label'] == 'Mestre') {
          if (achievement['current'] < achievement['target']) {
            achievement['current'] = totalXp.clamp(0, achievement['target']);
          }
          break;
        }
      }

      setState(() {});
    } catch (e) {
      print('Erro ao atualizar a conquista Mestre: $e');
    }
  }

  Future<void> updateScholarAchievement() async {
    try {
      final QuerySnapshot userPhasesDocs = await FirebaseFirestore.instance
          .collection('usuario_fase')
          .where('id_usuario', isEqualTo: widget.userId)
          .get();

      int totalStudyTimeInMinutes = userPhasesDocs.docs.fold(0, (sum, doc) {
        int studyTimeInSeconds = (doc['tempo_de_estudo'] ?? 0) as int;
        return sum + (studyTimeInSeconds ~/ 60);
      });

      for (var achievement in achievementsList) {
        if (achievement['label'] == 'Estudioso') {
          if (achievement['current'] < achievement['target']) {
            achievement['current'] =
                totalStudyTimeInMinutes.clamp(0, achievement['target']);
          }
          break;
        }
      }

      setState(() {});
    } catch (e) {
      print('Erro ao atualizar a conquista Estudioso: $e');
    }
  }

  List<Map<String, dynamic>> get mockAchievements => [
        {
          'image': 'assets/images/icons8-metrônomo-48.png',
          'label': 'Estudioso',
          'description': 'Tenha um tempo de estudo de 5 minutos',
          'current': 0,
          'target': 5,
          'level': 1,
        },
        {
          'image': 'assets/images/icons8-yoda-100.png',
          'label': 'Mestre',
          'description': 'Conquiste 50 Xp\'s',
          'current': 0,
          'target': 50,
          'level': 2,
        },
        {
          'image': 'assets/images/icons8-rei-60.png',
          'label': 'Rei',
          'description': 'Ganhe 3 coroas',
          'current': 0,
          'target': 3,
          'level': 3,
        },
        {
          'image': 'assets/images/icons8-estrela-de-natal-48.png',
          'label': 'Star',
          'description': 'Chegue ao nível 5 em alguma fase',
          'current': 0,
          'target': 5,
          'level': 4,
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        bigTitle('Conquistas'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 2.5,
              color: const Color(0xFFE5E5E5),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: achievementsList.length,
            itemBuilder: (context, index) {
              var achievement = achievementsList[index];

              return achievementItem(
                achievement['image'],
                achievement['label'],
                achievement['description'],
                achievement['current'],
                achievement['target'],
                achievement['level'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget achievementItem(String image, String label, String description,
      int current, int target, int level) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      height: 135,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          achievementImage(image, level),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              achievementLabel(label),
              const SizedBox(height: 5),
              achievementDescription(description),
              const SizedBox(height: 5),
              progressBar(current, target),
            ],
          ),
        ],
      ),
    );
  }

  Widget achievementImage(String image, int level) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(image, width: 80),
      ],
    );
  }

  Widget progressBar(int current, int target) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LinearPercentIndicator(
            width: 100,
            animation: true,
            lineHeight: 15.0,
            animationDuration: 100,
            percent: (current / target).clamp(0.0, 1.0),
            barRadius: const Radius.circular(10),
            backgroundColor: const Color(0xFFE5E5E5),
            progressColor: const Color(0xFFFFDE00),
          ),
          Text(
            '$current/$target',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFAFAFAF),
            ),
          ),
        ],
      ),
    );
  }

  Widget achievementDescription(String name) {
    return SizedBox(
      width: 200,
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xFF777777),
          fontSize: 15,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget achievementLabel(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget bigTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
