import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tcc_projeto/views/lesson_screen/lesson_screen.dart';

class CourseNode extends StatelessWidget {
  final String name;
  final String? image;
  final Color? color;
  final int? crown;
  final double? percent;
  final String idFase;
  final String idUsuario;

  const CourseNode(
    this.name, {
    required this.idFase,
    required this.idUsuario,
    this.image,
    this.color,
    this.crown,
    this.percent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LessonScreen(
                  idFase: idFase,
                  idUsuario: idUsuario,
                ),
              ),
            );
          },
          child: node(),
        ),
        const SizedBox(height: 5),
        courseName(),
      ],
    );
  }

  Widget node() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            progressCircle(),
            CircleAvatar(
              backgroundColor: color ?? const Color(0xFF2B70C9),
              radius: 37,
            ),
            Image.asset(
              image ?? 'assets/images/egg.png',
              width: 42,
            ),
            subCrown(),
          ],
        ),
      ],
    );
  }

  Widget progressCircle() {
    return Transform.rotate(
      angle: 2.7,
      child: CircularPercentIndicator(
        radius: 55.0,
        lineWidth: 10.0,
        percent: percent!,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: const Color(0xFFFFC800),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }

  Widget subCrown() {
    return Positioned(
      right: 0,
      bottom: 5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/crown.png', width: 40),
          Text(
            '${crown == null || crown == 0 ? '' : crown}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xFFB66E28),
            ),
          ),
        ],
      ),
    );
  }

  Widget courseName() {
    return Text(
      name,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }
}
