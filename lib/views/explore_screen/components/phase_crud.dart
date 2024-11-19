import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'phase_form.dart';
import 'exercise_linker.dart';

class PhaseCrud extends StatefulWidget {
  const PhaseCrud({Key? key}) : super(key: key);

  @override
  State<PhaseCrud> createState() => _PhaseCrudState();
}

class _PhaseCrudState extends State<PhaseCrud> {
  String? _phaseId;
  List<DocumentSnapshot> _phases = []; // Armazena as fases em ordem

  void _openPhaseForm(
      {String? phaseId, String? name, Color? color, String? imagePath}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: PhaseForm(
          phaseId: phaseId,
          name: name,
          initialColor: color ?? Colors.blue,
          initialImagePath: imagePath ?? 'assets/images/default.png',
          onSave: _fetchPhases,
        ),
      ),
    );
  }

  Future<void> _deletePhase(String phaseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta fase?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('fase')
            .doc(phaseId)
            .delete();

        final linkedExercisesSnapshot = await FirebaseFirestore.instance
            .collection('fase_exercicio')
            .where('id_fase', isEqualTo: phaseId)
            .get();

        for (var doc in linkedExercisesSnapshot.docs) {
          await doc.reference.delete();
        }

        final userPhaseLinksSnapshot = await FirebaseFirestore.instance
            .collection('usuario_fase')
            .where('id_fase', isEqualTo: phaseId)
            .get();

        for (var doc in userPhaseLinksSnapshot.docs) {
          await doc.reference.delete();
        }

        // Chama o método para atualizar as fases na tela
        _fetchPhases();

        // Exibe o SnackBar de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Erro ao excluir fase: $e');
      }
    }
  }

  void _openExerciseLinker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ExerciseLinker(
          phaseId: _phaseId!,
          linkedExercises: [],
          onExercisesLinked: _fetchPhases,
        );
      },
    );
  }

  Future<void> _fetchPhases() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('fase')
        .orderBy('prioridade')
        .get();
    setState(() {
      _phases = snapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPhases();
  }

  Future<void> _updatePriorities() async {
    for (int index = 0; index < _phases.length; index++) {
      final phase = _phases[index];
      await FirebaseFirestore.instance
          .collection('fase')
          .doc(phase.id)
          .update({'prioridade': index + 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Fases'),
        automaticallyImplyLeading: false,
      ),
      body: ReorderableListView(
        children: [
          for (int index = 0; index < _phases.length; index++)
            ListTile(
              key: ValueKey(_phases[index].id),
              title: Text(_phases[index].get('nome') ?? 'Nome não disponível'),
              subtitle: Text('Prioridade: ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openPhaseForm(
                      phaseId: _phases[index].id,
                      name: _phases[index].get('nome'),
                      color: Color(
                          int.parse(_phases[index].get('cor'), radix: 16)),
                      imagePath: _phases[index].get('imagem'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deletePhase(_phases[index].id),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _phaseId = _phases[index].id;
                });
                _openExerciseLinker();
              },
            ),
        ],
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _phases.removeAt(oldIndex);
            _phases.insert(newIndex, item);
          });
          _updatePriorities();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPhaseForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
