import 'package:flutter/material.dart';

class CenterDisplay extends StatelessWidget {
  const CenterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/EPROG-logo.png', height: 150),
          const SizedBox(height: 5),
          Image.asset('assets/images/EPROG.png', width: 125, height: 40),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
