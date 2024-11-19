import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateExercise extends StatefulWidget {
  final String exerciseId;
  final String enunciado;
  final String nivel;
  final String tipo;
  final String resposta;
  final List<String> alternativas;
  final String? codigo;

  const CreateExercise({
    Key? key,
    required this.exerciseId,
    required this.enunciado,
    required this.nivel,
    required this.tipo,
    required this.resposta,
    required this.alternativas,
    required this.codigo,
  }) : super(key: key);

  @override
  _CreateExerciseState createState() => _CreateExerciseState();
}

class _CreateExerciseState extends State<CreateExercise> {
  late TextEditingController enunciadoController;
  late TextEditingController respostaController;
  late TextEditingController codigoController;
  String? selectedTipo;
  List<TextEditingController> alternativasControllers = [];
  double nivel = 1;
  int? selectedRespostaIndex;

  @override
  void initState() {
    super.initState();
    enunciadoController = TextEditingController(text: widget.enunciado);
    respostaController = TextEditingController(text: widget.resposta);
    codigoController = TextEditingController(text: widget.codigo ?? "");
    selectedTipo = ['dissertativo', 'alternativo'].contains(widget.tipo)
        ? widget.tipo
        : 'dissertativo';

    for (var alternativa in widget.alternativas) {
      alternativasControllers.add(TextEditingController(text: alternativa));
    }

    selectedRespostaIndex = widget.alternativas.indexOf(widget.resposta);
    nivel = (double.tryParse(widget.nivel) ?? 1).clamp(1.0, 5.0);
  }

  @override
  void dispose() {
    enunciadoController.dispose();
    respostaController.dispose();
    codigoController.dispose();
    for (var controller in alternativasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void adicionarAlternativa() {
    setState(() {
      alternativasControllers.add(TextEditingController());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alternativa adicionada')),
    );
  }

  void removerAlternativa(int index) {
    setState(() {
      alternativasControllers[index].dispose();
      alternativasControllers.removeAt(index);

      if (selectedRespostaIndex == index) {
        selectedRespostaIndex = null;
      } else if (selectedRespostaIndex != null &&
          selectedRespostaIndex! > index) {
        selectedRespostaIndex = selectedRespostaIndex! - 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alternativa removida')),
    );
  }

  Future<void> salvarExercicio() async {
    DocumentReference exercicioRef;

    int nivelInt = nivel.toInt();

    if (nivelInt < 1 || nivelInt > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nível de dificuldade deve ser entre 1 e 5')),
      );
      return;
    }

    if (widget.exerciseId.isEmpty) {
      exercicioRef = FirebaseFirestore.instance.collection('exercicio').doc();
      await exercicioRef.set({
        'enunciado': enunciadoController.text,
        'nivel_de_dificuldade': nivelInt,
        'tipo_de_exercicio': selectedTipo,
        'codigo':
            codigoController.text.isNotEmpty ? codigoController.text : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício criado com sucesso')),
      );
    } else {
      exercicioRef = FirebaseFirestore.instance
          .collection('exercicio')
          .doc(widget.exerciseId);

      await exercicioRef.update({
        'enunciado': enunciadoController.text,
        'nivel_de_dificuldade': nivelInt,
        'tipo_de_exercicio': selectedTipo,
        'codigo':
            codigoController.text.isNotEmpty ? codigoController.text : null,
      });
      print(
          'odigoController.text.isNotEmpty: ${codigoController.text.isNotEmpty}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício atualizado com sucesso')),
      );
    }

    if (selectedTipo == 'alternativo') {
      List<String> alternativas =
          alternativasControllers.map((c) => c.text).toList();

      if (selectedRespostaIndex == null ||
          selectedRespostaIndex! < 0 ||
          selectedRespostaIndex! >= alternativas.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a resposta correta')),
        );
        return;
      }

      String respostaCorreta = alternativas[selectedRespostaIndex!];

      QuerySnapshot alternativaSnapshot = await FirebaseFirestore.instance
          .collection('alternativa')
          .where('id_exercicio', isEqualTo: exercicioRef.id)
          .get();

      if (alternativaSnapshot.docs.isEmpty) {
        DocumentReference alternativaRef =
            FirebaseFirestore.instance.collection('alternativa').doc();
        await alternativaRef.set({
          'id_exercicio': exercicioRef.id,
          'alternativas': alternativas,
          'resposta': respostaCorreta,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alternativas criadas com sucesso')),
        );
      } else {
        for (var doc in alternativaSnapshot.docs) {
          DocumentReference alternativaRef = doc.reference;
          await alternativaRef.update({
            'alternativas': alternativas,
            'resposta': respostaCorreta,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Alternativas atualizadas com sucesso')),
          );
        }
      }
    } else if (selectedTipo == 'dissertativo') {
      QuerySnapshot dissertativoSnapshot = await FirebaseFirestore.instance
          .collection('dissertativo')
          .where('id_exercicio', isEqualTo: exercicioRef.id)
          .get();

      if (dissertativoSnapshot.docs.isEmpty) {
        DocumentReference dissertativoRef =
            FirebaseFirestore.instance.collection('dissertativo').doc();
        await dissertativoRef.set({
          'id_exercicio': exercicioRef.id,
          'resposta_correta': respostaController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Exercício dissertativo criado com sucesso')),
        );
      } else {
        for (var doc in dissertativoSnapshot.docs) {
          DocumentReference dissertativoRef = doc.reference;
          await dissertativoRef.update({
            'resposta_correta': respostaController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Exercício dissertativo atualizado com sucesso')),
          );
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Exercício'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: enunciadoController,
                decoration: const InputDecoration(labelText: 'Enunciado'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: codigoController,
                maxLines: null, // Permite altura dinâmica
                decoration: InputDecoration(
                  labelText: 'Código',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 122, 122, 122),
                  border: const OutlineInputBorder(),
                  hintText: 'Digite o código aqui...',
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(137, 255, 255, 255)),
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nível de Dificuldade:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: nivel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: nivel.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        nivel = value;
                      });
                    },
                  ),
                  Text('Nível selecionado: ${nivel.toInt()}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              DropdownButton<String>(
                value: selectedTipo,
                hint: const Text('Selecione o Tipo de Exercício'),
                items: <String>['dissertativo', 'alternativo']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTipo = newValue;
                  });
                },
              ),
              if (selectedTipo == 'dissertativo') ...[
                TextField(
                  controller: respostaController,
                  decoration:
                      const InputDecoration(labelText: 'Resposta Correta'),
                ),
              ],
              if (selectedTipo == 'alternativo') ...[
                const Text(
                  'Alternativas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...alternativasControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Alternativa ${index + 1}',
                          ),
                        ),
                      ),
                      Checkbox(
                        value: selectedRespostaIndex == index,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedRespostaIndex =
                                value == true ? index : null;
                          });
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removerAlternativa(index),
                      ),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: adicionarAlternativa,
                  child: const Text('Adicionar Alternativa'),
                ),
              ],
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: salvarExercicio,
                child: const Text('Salvar Exercício'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
