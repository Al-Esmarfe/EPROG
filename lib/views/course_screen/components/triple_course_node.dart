import 'package:flutter/material.dart';

import 'course_node.dart';

class TripleCourseNode extends StatelessWidget {
  final CourseNode node1;
  final CourseNode node2;
  final CourseNode node3;

  const TripleCourseNode(this.node1, this.node2, this.node3, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        node1,
        const SizedBox(width: 5),
        node2,
        const SizedBox(width: 5),
        node3,
      ],
    );
  }
}
