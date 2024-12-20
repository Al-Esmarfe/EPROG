import 'package:flutter/material.dart';

import 'course_node.dart';

class DoubleCourseNode extends StatelessWidget {
  final CourseNode node1;
  final CourseNode node2;

  const DoubleCourseNode(this.node1, this.node2, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        node1,
        const SizedBox(width: 20),
        node2,
      ],
    );
  }
}
