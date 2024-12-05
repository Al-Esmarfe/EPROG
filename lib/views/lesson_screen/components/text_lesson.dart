import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class TextLesson extends StatefulWidget {
  final String enunciado;
  final String? codigo;
  final String idExercicio;
  final Widget checkButton;
  final Function(bool) onCheckAnswer;
  final String? correctAnswer;

  const TextLesson({
    required this.enunciado,
    required this.codigo,
    required this.idExercicio,
    required this.checkButton,
    required this.onCheckAnswer,
    this.correctAnswer,
    Key? key,
  }) : super(key: key);

  @override
  State<TextLesson> createState() => _TextLessonState();

  String? get getCorrectAnswer => correctAnswer;
}

class _TextLessonState extends State<TextLesson> {
  final TextEditingController _controller = TextEditingController();
  bool isCorrect = false;
  String? correctAnswer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnswer();
  }

  Future<void> fetchAnswer() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('dissertativo')
          .where('id_exercicio', isEqualTo: widget.idExercicio)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        setState(() {
          correctAnswer = doc['resposta_correta'] as String;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar resposta correta: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    if (correctAnswer == null) return;

    setState(() {
      final userInput = removeDiacritics(_controller.text.trim().toLowerCase());
      final correctAnswerNormalized =
          removeDiacritics(correctAnswer!.trim().toLowerCase());

      isCorrect = userInput == correctAnswerNormalized;
      widget.onCheckAnswer(isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              instruction(widget.enunciado),
              const SizedBox(height: 15),
              if (widget.codigo != null && widget.codigo!.isNotEmpty)
                questionRow(widget.codigo!),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite sua resposta aqui',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  onChanged: (text) => _checkAnswer(),
                ),
              ),
              const SizedBox(height: 10),
              widget.checkButton,
            ],
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TextLesson oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.idExercicio != widget.idExercicio) {
      _controller.clear();
      setState(() {
        isCorrect = false;
        isLoading = true;
      });
      fetchAnswer();
    }
  }
}
