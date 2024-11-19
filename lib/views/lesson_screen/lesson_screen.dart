import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_projeto/views/lesson_screen/components/completation_screen.dart';
import 'package:tcc_projeto/views/lesson_screen/components/list_lesson.dart';
import 'package:tcc_projeto/views/lesson_screen/components/text_lesson.dart';
import 'components/lesson_app_bar.dart';

class LessonScreen extends StatefulWidget {
  final String idFase;
  final String idUsuario;

  const LessonScreen(
      {required this.idFase, required this.idUsuario, super.key});

  @override
  State<StatefulWidget> createState() {
    return LessonScreenState();
  }
}

class LessonScreenState extends State<LessonScreen> {
  double percent = 0.2;
  int index = 0;
  List<dynamic> lessons = [];
  List<dynamic> failedLessons = [];
  Map<String, String> correctAnswersMap = {};
  bool isLoading = true;
  bool isAnswerCorrect = false;
  int pontos = 0;
  late Timer _timer;
  int _timeSpent = 0;
  String? correctAnswer;

  @override
  void initState() {
    super.initState();
    fetchLessons(widget.idFase);
    _startTimer();
  }

  void _advanceToNextLesson() {
    setState(() {
      if (index < lessons.length - 1) {
        index++;
        percent = (index + 1) / lessons.length;
        isAnswerCorrect = false;
      } else {
        _finishLessons();
      }
    });
  }

  Future<void> fetchLessons(String idFase) async {
    try {
      QuerySnapshot faseExercicioSnapshot = await FirebaseFirestore.instance
          .collection('fase_exercicio')
          .where('id_fase', isEqualTo: idFase)
          .get();

      List<String> exercicioIds = faseExercicioSnapshot.docs
          .map((doc) => doc['id_exercicio'] as String)
          .toList();

      if (exercicioIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      QuerySnapshot exercicioSnapshot = await FirebaseFirestore.instance
          .collection('exercicio')
          .where(FieldPath.documentId, whereIn: exercicioIds)
          .get();

      List<dynamic> lessonsData = [];

      for (var doc in exercicioSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String exercicioId = doc.id;

        int dificuldade = data['nivel_de_dificuldade'] ?? 1;

        switch (data['tipo_de_exercicio']) {
          case 'alternativo':
            lessonsData.add(
              ListLesson(
                exercicioId,
                data['enunciado'],
                data['codigo'],
                checkButton: bottomButton(
                    context, 'CONFIRMAR', dificuldade, exercicioId),
                onCheckAnswer: (isCorrect) {
                  setState(() {
                    isAnswerCorrect = isCorrect;
                    if (isCorrect) {
                      pontos += dificuldade * 10;
                      failedLessons.remove(exercicioId);
                    } else {
                      failedLessons.add(exercicioId);
                    }
                  });
                },
              ),
            );
            fetchAnswer('alternativo', exercicioId);
            break;

          case 'dissertativo':
            lessonsData.add(
              TextLesson(
                enunciado: data['enunciado'],
                codigo: data['codigo'],
                idExercicio: exercicioId,
                checkButton: bottomButton(
                    context, 'CONFIRMAR', dificuldade, exercicioId),
                onCheckAnswer: (isCorrect) {
                  setState(() {
                    isAnswerCorrect = isCorrect;
                    if (isCorrect) {
                      pontos += dificuldade * 10;
                      failedLessons.remove(exercicioId);
                    } else {
                      failedLessons.add(exercicioId);
                    }
                  });
                },
              ),
            );
            fetchAnswer('dissertativo', exercicioId);
            break;
        }
      }

      if (failedLessons.isNotEmpty) {
        List<dynamic> failedLessonsData = [];

        for (var failedLessonId in failedLessons) {
          var failedLesson = lessonsData.firstWhere(
              (lesson) => (lesson.idExercicio == failedLessonId),
              orElse: () => null);
          if (failedLesson != null) {
            failedLessonsData.add(failedLesson);
          }
        }

        lessonsData.addAll(failedLessonsData);
      }

      setState(() {
        lessons = lessonsData;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar lições: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAnswer(String tipo, String exercicioId) async {
    try {
      if (tipo == 'dissertativo') {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('dissertativo')
            .where('id_exercicio', isEqualTo: exercicioId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = snapshot.docs.first;
          setState(() {
            correctAnswersMap[exercicioId] = doc['resposta_correta'] as String;
          });
        }
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('alternativa')
            .where('id_exercicio', isEqualTo: exercicioId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = snapshot.docs.first;
          setState(() {
            correctAnswersMap[exercicioId] = doc['resposta'] as String;
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar resposta correta: $e');
    }
  }

  Widget bottomButton(
      BuildContext context, String title, int dificuldade, String exercicioId) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          String? answer = correctAnswersMap[exercicioId];
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialog(
                context,
                isAnswerCorrect ? 'Parabéns!' : 'Resposta incorreta',
                isAnswerCorrect,
                answer,
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isAnswerCorrect ? const Color(0xFF58CC02) : Colors.red,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget dialog(BuildContext context, String title, bool isAnswerCorrect,
      String? correctAnswer) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: isAnswerCorrect ? 120 : 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isAnswerCorrect ? const Color(0xFFd7ffb8) : Colors.redAccent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dialogTitle(title),
            if (!isAnswerCorrect && correctAnswer != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Resposta correta: $correctAnswer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _advanceToNextLesson();
                },
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LessonAppBar(percent: percent),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessons.isNotEmpty && index < lessons.length
              ? lessons[index]
              : const Text('Nenhuma lição disponível.'),
    );
  }

  void _finishLessons() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(
          idFase: widget.idFase,
          idUsuario: widget.idUsuario,
          pontos: pontos,
          tempoDeEstudo: _timeSpent,
        ),
      ),
    );
  }

  Widget dialogTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.only(left: 15),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF43C000),
          ),
          child: Text(text),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpent++;
      });
    });
  }
}
