import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListLesson extends StatefulWidget {
  final String Idexercise;
  final Widget checkButton;
  final String question;
  final String? codigo;
  final Function(bool) onCheckAnswer;
  final String? correctAnswer;

  const ListLesson(
    this.Idexercise,
    this.question,
    this.codigo, {
    required this.checkButton,
    required this.onCheckAnswer,
    this.correctAnswer,
    Key? key,
  }) : super(key: key);

  @override
  State<ListLesson> createState() => _ListLessonState();

  String? get getCorrectAnswer => correctAnswer;
}

class _ListLessonState extends State<ListLesson> {
  late Future<List<String>> alternativesFuture;
  String? selectedOption;
  String correctAnswer = '';
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    alternativesFuture = fetchAlternatives();
  }

  @override
  void didUpdateWidget(ListLesson oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.Idexercise != widget.Idexercise) {
      alternativesFuture = fetchAlternatives();
      selectedOption = null;
      correctAnswer = '';
    }
  }

  Future<List<String>> fetchAlternatives() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('alternativa')
        .where('id_exercicio', isEqualTo: widget.Idexercise)
        .get();

    List<String> alternatives = [];
    for (var doc in snapshot.docs) {
      if (doc.data() != null &&
          (doc.data() as Map<String, dynamic>).containsKey('alternativas') &&
          doc['alternativas'] is List) {
        List<dynamic> texts = doc['alternativas'];
        alternatives.addAll(texts
            .map((text) => text.toString())
            .where((text) => text.isNotEmpty));
      }

      if ((doc.data() as Map<String, dynamic>).containsKey('resposta')) {
        correctAnswer = doc['resposta'];
      }
    }

    return alternatives;
  }

  void resetState() {
    setState(() {
      selectedOption = null;
      correctAnswer = '';
      isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        instruction(widget.question),
        const SizedBox(height: 15),
        if (widget.codigo != null && widget.codigo!.isNotEmpty)
          questionRow(widget.codigo!),
        const SizedBox(height: 5),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: alternativesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Erro ao carregar as alternativas: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('Nenhuma alternativa disponível'));
              }

              List<String> alternatives = snapshot.data!;
              return Center(
                child: ListView.builder(
                  itemCount: alternatives.length,
                  itemBuilder: (context, index) {
                    return listChoice(alternatives[index]);
                  },
                ),
              );
            },
          ),
        ),
        widget.checkButton,
      ],
    );
  }

  Widget listChoice(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = title;
          isCorrect = selectedOption?.replaceAll('\n', '').trim() ==
              correctAnswer.replaceAll('\n', '').trim();
          this.correctAnswer = correctAnswer;
          widget.onCheckAnswer(isCorrect);
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
              selectedOption == title ? Colors.green : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 2.5,
            color: const Color(0xFFE5E5E5),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }

  Widget questionRow(String codigo) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(left: 15, bottom: 5, right: 15),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              codigo,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B4B4B)),
            ),
          )
        ],
      ),
    );
  }

  Widget instruction(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 15),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
