import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('usuario').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['nome'];
          _profileImageUrl = userDoc[
              'foto_url']; // Certifique-se que 'foto_url' existe no Firestore
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('usuario').doc(user.uid).update({
          'nome': _nameController.text,
          'foto_url': _profileImageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao atualizar perfil: $e'),
        ));
      }
    }
  }

  void _chooseProfileImage() {
    final List<String> mockImages = [
      'assets/images/cyan.png',
      'assets/images/chicken.png',
      'assets/images/yellow.png',
      'assets/images/profile.png',
      'assets/images/man.png',
      'assets/images/ant.png',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: mockImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _profileImageUrl = mockImages[index];
                });
                Navigator.of(context).pop();
              },
              child: Image.asset(mockImages[index], fit: BoxFit.cover),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text(
            'Tem certeza de que deseja excluir sua conta? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot userPhases = await _firestore
            .collection('usuario_fase')
            .where('id_usuario', isEqualTo: user.uid)
            .get();

        for (var doc in userPhases.docs) {
          await doc.reference.delete();
        }

        QuerySnapshot userAchievements = await _firestore
            .collection('conquistas')
            .where('id_usuario', isEqualTo: user.uid)
            .get();

        for (var doc in userAchievements.docs) {
          await doc.reference.delete();
        }

        await _firestore.collection('usuario').doc(user.uid).delete();
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conta e dados relacionados excluídos com sucesso!'),
        ));

        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao excluir conta: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? AssetImage(_profileImageUrl!) as ImageProvider
                    : AssetImage('assets/default_profile.png'),
                child: GestureDetector(
                  onTap: _chooseProfileImage,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Salvar Alterações'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmDeleteAccount,
                child:
                    Text('Apagar Conta', style: TextStyle(color: Colors.red)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
