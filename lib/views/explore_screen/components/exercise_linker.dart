import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLinker extends StatefulWidget {
  final String phaseId;
  final List<String> linkedExercises;
  final Function() onExercisesLinked;

  const ExerciseLinker({
    Key? key,
    required this.phaseId,
    required this.linkedExercises,
    required this.onExercisesLinked,
  }) : super(key: key);

  @override
  _ExerciseLinkerState createState() => _ExerciseLinkerState();
}

class _ExerciseLinkerState extends State<ExerciseLinker> {
  late List<String> _linkedExercises = [];

  @override
  void initState() {
    super.initState();
    _fetchLinkedExercises();
  }

  Future<void> _fetchLinkedExercises() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('fase_exercicio')
        .where('id_fase', isEqualTo: widget.phaseId)
        .get();

    setState(() {
      _linkedExercises = snapshot.docs
          .map((doc) => doc.get('id_exercicio') as String)
          .toList();
    });
  }

  Future<void> _linkOrUnlinkExercise(String exerciseId, bool isLinked) async {
    final collection = FirebaseFirestore.instance.collection('fase_exercicio');

    if (isLinked) {
      // Desvincular exercício
      final querySnapshot = await collection
          .where('id_fase', isEqualTo: widget.phaseId)
          .where('id_exercicio', isEqualTo: exerciseId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      _linkedExercises.remove(exerciseId);
    } else {
      // Vincular exercício
      await collection.add({
        'id_fase': widget.phaseId,
        'id_exercicio': exerciseId,
      });
      _linkedExercises.add(exerciseId);
    }

    setState(() {});
    widget
        .onExercisesLinked(); // Atualiza a lista de exercícios vinculados no `PhaseCrud`
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('exercicio').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var exercises = snapshot.data!.docs;
        return ListView(
          children: exercises.map((doc) {
            String exerciseId = doc.id;
            String exerciseName = doc.get('enunciado') ?? 'Nome não disponível';

            bool isLinked = _linkedExercises.contains(exerciseId);

            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exerciseName),
                  if (isLinked)
                    const Text(
                      'Já vinculado',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () async =>
                    await _linkOrUnlinkExercise(exerciseId, isLinked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLinked ? Colors.red : Colors.blue,
                ),
                child: Text(isLinked ? 'Desvincular' : 'Vincular'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
