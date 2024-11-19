import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  final int totalPontos;
  final int totalTempoEstudo;
  final int totalCoroas; // Adicionando o total de coroas

  const Statistics({
    super.key,
    required this.totalPontos,
    required this.totalTempoEstudo,
    required this.totalCoroas, // Adicionando como parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360), // Limite de largura
      child: GridView.count(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: (1 / 1.2),
        children: [
          statBox(
              'assets/images/chest.png', totalPontos.toString(), 'Total XP'),
          statBox('assets/images/electric.png', totalTempoEstudo.toString(),
              'Tempo de Estudo'),
          statBox('assets/images/crown.png', totalCoroas.toString(), 'Coroas'),
        ],
      ),
    );
  }

  Widget statBox(String iconImage, String record, String label) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconImage, width: 30),
            const SizedBox(height: 5),
            Text(
              record,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B4B4B),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFAFAFAF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bigTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
