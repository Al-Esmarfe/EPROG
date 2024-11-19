import 'package:flutter/material.dart';

class GridLesson extends StatelessWidget {
  final Widget checkButton;
  const GridLesson({required this.checkButton, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          instruction('Select the correct image'),
          questionRow('con kiến'),
          GridView.count(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
            children: [
              gridChoice('assets/images/ant.png', 'ant'),
              gridChoice('assets/images/student.png', 'student'),
              gridChoice('assets/images/chicken.png', 'chicken'),
              gridChoice('assets/images/food.png', 'food'),
            ],
          ),
          checkButton,
        ],
      ),
    );
  }

  Widget gridChoice(String image, String title) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 2.5,
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(image, scale: 0.5),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget questionRow(String question) {
    return Container(
      margin: const EdgeInsets.only(left: 15, bottom: 5),
      child: Row(
        children: [
          speakButton(),
          const SizedBox(width: 15),
          Text(
            question,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B4B4B)),
          )
        ],
      ),
    );
  }

  Widget speakButton() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF1CB0F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.volume_up,
        color: Colors.white,
        size: 35,
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
