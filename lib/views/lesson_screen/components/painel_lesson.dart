import 'package:flutter/material.dart';

class PanelLesson extends StatelessWidget {
  final String enunciado;
  final String frase;
  final List<String> opcoes;
  final Widget checkButton;

  const PanelLesson(this.enunciado, this.frase, this.opcoes,
      {required this.checkButton, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(enunciado),
        Text(frase),
        Wrap(
          children: opcoes.map((opcao) {
            return ElevatedButton(
              onPressed: () {},
              child: Text(opcao),
            );
          }).toList(),
        ),
        checkButton,
      ],
    );
  }
}
