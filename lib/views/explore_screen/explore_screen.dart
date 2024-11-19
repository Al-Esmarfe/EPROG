import 'package:flutter/material.dart';
import 'package:tcc_projeto/views/explore_screen/components/exercise_crud.dart';
import 'package:tcc_projeto/views/explore_screen/components/phase_crud.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PhaseCrud(),
          ),
          Expanded(
            child: ExerciseCrud(),
          ),
        ],
      ),
    );
  }
}
