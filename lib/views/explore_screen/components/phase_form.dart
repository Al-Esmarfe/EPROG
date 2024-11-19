import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PhaseForm extends StatefulWidget {
  final String? phaseId;
  final String? name;
  final Color initialColor;
  final String initialImagePath;
  final Function() onSave;

  const PhaseForm({
    Key? key,
    this.phaseId,
    this.name,
    this.initialColor = Colors.blue,
    this.initialImagePath = 'assets/images/default.png',
    required this.onSave,
  }) : super(key: key);

  @override
  State<PhaseForm> createState() => _PhaseFormState();
}

class _PhaseFormState extends State<PhaseForm> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String _selectedImagePath = 'assets/images/default.png';
  final List<String> _imagePaths = [
    'assets/images/hand.png',
    'assets/images/heart.png',
    'assets/images/heel.png',
    'assets/images/impostor.png',
    'assets/images/chest.png',
    'assets/images/cyan.png',
    'assets/images/dumbbell.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _selectedColor = widget.initialColor;
    _selectedImagePath = widget.initialImagePath;
  }

  Future<void> _createOrUpdatePhase() async {
    try {
      final String name = _nameController.text;

      if (widget.phaseId == null) {
        final phasesSnapshot = await FirebaseFirestore.instance
            .collection('fase')
            .orderBy('prioridade', descending: true)
            .limit(1)
            .get();

        int newPriority = 1;
        if (phasesSnapshot.docs.isNotEmpty) {
          newPriority = phasesSnapshot.docs.first['prioridade'] + 1;
        }

        DocumentReference phaseRef =
            await FirebaseFirestore.instance.collection('fase').add({
          'nome': name,
          'cor': _selectedColor.value.toRadixString(16),
          'imagem': _selectedImagePath,
          'prioridade': newPriority,
          'created_at': DateTime.now(),
        });

        final usersSnapshot =
            await FirebaseFirestore.instance.collection('usuario').get();

        for (var userDoc in usersSnapshot.docs) {
          final userId = userDoc.id;
          final docId = "${userId}_${phaseRef.id}";

          await FirebaseFirestore.instance
              .collection('usuario_fase')
              .doc(docId)
              .set({
            'id_usuario': userId,
            'id_fase': phaseRef.id,
            'crown': 0,
            'percent': 0.0,
            'tempo_de_estudo': 0,
            'pontos': 0,
          });
        }

        // Exibir a mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fase criada com sucesso!')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('fase')
            .doc(widget.phaseId)
            .update({
          'nome': name,
          'cor': _selectedColor.value.toRadixString(16),
          'imagem': _selectedImagePath,
        });

        // Exibir a mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fase atualizada com sucesso!')),
        );
      }

      widget.onSave();
      Navigator.of(context).pop();
    } catch (e) {
      print('Erro ao salvar fase: $e');
    }
  }

  Future<void> _deletePhase() async {
    try {
      if (widget.phaseId != null) {
        await FirebaseFirestore.instance
            .collection('fase')
            .doc(widget.phaseId)
            .delete();

        final linkedExercisesSnapshot = await FirebaseFirestore.instance
            .collection('fase_exercicio')
            .where('id_fase', isEqualTo: widget.phaseId)
            .get();

        for (var doc in linkedExercisesSnapshot.docs) {
          await doc.reference.delete();
        }

        final userPhaseLinksSnapshot = await FirebaseFirestore.instance
            .collection('usuario_fase')
            .where('id_fase', isEqualTo: widget.phaseId)
            .get();

        for (var doc in userPhaseLinksSnapshot.docs) {
          await doc.reference.delete();
        }

        // Exibir a mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fase excluída com sucesso!')),
        );

        widget.onSave();
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Erro ao excluir fase: $e');
    }
  }

  void _openColorPicker() async {
    final Color? newColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escolher Cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedColor),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (newColor != null) {
      setState(() {
        _selectedColor = newColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        const SizedBox(height: 16),
        Text('Cor'),
        GestureDetector(
          onTap: _openColorPicker,
          child: Container(
            width: double.infinity,
            height: 50,
            color: _selectedColor,
            child: const Center(
              child:
                  Text('Escolher Cor', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Imagem'),
        DropdownButton<String>(
          value: _imagePaths.contains(_selectedImagePath)
              ? _selectedImagePath
              : _imagePaths.first,
          items: _imagePaths.map((path) {
            return DropdownMenuItem<String>(
              value: path,
              child: Row(
                children: [
                  Image.asset(path, width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(path.split('/').last),
                ],
              ),
            );
          }).toList(),
          onChanged: (newPath) {
            if (newPath != null) {
              setState(() {
                _selectedImagePath = newPath;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _createOrUpdatePhase,
                  child: Text(widget.phaseId == null ? 'Criar' : 'Atualizar'),
                ),
              ],
            ),
            if (widget.phaseId != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deletePhase,
              ),
          ],
        ),
      ],
    );
  }
}
