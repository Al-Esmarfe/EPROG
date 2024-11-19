import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_exercise.dart';

class ExerciseCrud extends StatelessWidget {
  const ExerciseCrud({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Exercícios'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('exercicio').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String enunciado = doc.get('enunciado')?.toString() ??
                  'Enunciado não disponível';
              String nivel = doc.get('nivel_de_dificuldade')?.toString() ??
                  'Nível não especificado';
              String tipo = doc.get('tipo_de_exercicio')?.toString() ??
                  'Tipo não especificado';
              String codigo = doc.get('codigo')?.toString() ?? '';

              return ListTile(
                title: Text(enunciado),
                subtitle: Text('Nível: $nivel, Tipo: $tipo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        DocumentSnapshot docExercicio = await FirebaseFirestore
                            .instance
                            .collection('exercicio')
                            .doc(doc.id)
                            .get();

                        String tipo = (docExercicio.data()
                                as Map<String, dynamic>)['tipo_de_exercicio'] ??
                            'dissertativo';
                        String resposta = '';
                        String alternativas = '';
                        int nivel = 0;

                        if ((docExercicio.data()
                                as Map<String, dynamic>)['nivel_de_dificuldade']
                            is int) {
                          nivel = (docExercicio.data()
                              as Map<String, dynamic>)['nivel_de_dificuldade'];
                        } else {
                          nivel = int.tryParse((docExercicio.data() as Map<
                                          String,
                                          dynamic>)['nivel_de_dificuldade']
                                      .toString() ??
                                  '') ??
                              0;
                        }

                        if (tipo == 'alternativo') {
                          DocumentSnapshot? docAlternativa =
                              await FirebaseFirestore.instance
                                  .collection('alternativa')
                                  .where('id_exercicio', isEqualTo: doc.id)
                                  .limit(1)
                                  .get()
                                  .then((querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              return querySnapshot.docs.first;
                            }
                            return null;
                          });

                          if (docAlternativa != null) {
                            resposta = (docAlternativa.data()
                                    as Map<String, dynamic>)['resposta'] ??
                                '';
                            alternativas = ((docAlternativa.data() as Map<
                                            String, dynamic>)['alternativas']
                                        as List<dynamic>?)
                                    ?.join(', ') ??
                                '';
                          }
                        } else if (tipo == 'dissertativo') {
                          DocumentSnapshot? docDissertativo =
                              await FirebaseFirestore.instance
                                  .collection('dissertativo')
                                  .where('id_exercicio', isEqualTo: doc.id)
                                  .limit(1)
                                  .get()
                                  .then((querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              return querySnapshot.docs.first;
                            }
                            return null;
                          });

                          if (docDissertativo != null) {
                            resposta = (docDissertativo.data() as Map<String,
                                    dynamic>)['resposta_correta'] ??
                                '';
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateExercise(
                              exerciseId: doc.id,
                              enunciado: (docExercicio.data()
                                      as Map<String, dynamic>)['enunciado'] ??
                                  '',
                              codigo: codigo,
                              nivel: nivel.toString(),
                              tipo: tipo,
                              resposta: resposta,
                              alternativas: alternativas.split(', '),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmDelete(context, doc.id);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateExercise(
                exerciseId: '',
                enunciado: '',
                codigo: '',
                nivel: '',
                tipo: '',
                resposta: '',
                alternativas: [],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Função para exibir o modal de confirmação de exclusão
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Exercício'),
          content: const Text(
              'Você tem certeza de que deseja excluir este exercício?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                DocumentSnapshot docExercicio = await FirebaseFirestore.instance
                    .collection('exercicio')
                    .doc(docId)
                    .get();

                String tipo = (docExercicio.data()
                    as Map<String, dynamic>)['tipo_de_exercicio'];

                if (tipo == 'dissertativo') {
                  await FirebaseFirestore.instance
                      .collection('dissertativo')
                      .where('id_exercicio', isEqualTo: docId)
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.delete();
                    });
                  });
                } else if (tipo == 'alternativo') {
                  await FirebaseFirestore.instance
                      .collection('alternativa')
                      .where('id_exercicio', isEqualTo: docId)
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.delete();
                    });
                  });
                }

                await FirebaseFirestore.instance
                    .collection('exercicio')
                    .doc(docId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Exercício excluído com sucesso!')),
                );
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
