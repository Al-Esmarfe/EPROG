import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login com Email e Senha
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erro ao fazer login: $e");
      return null;
    }
  }

  static final FirebaseAuth _authInstance = FirebaseAuth.instance;

  // Função para resetar a senha
  static Future<void> resetPassword(String email) async {
    try {
      await _authInstance.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow; // Propaga o erro para ser tratado no componente chamador
    }
  }

  // Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print("Erro ao fazer login com Google: $e");
      return null;
    }
    return null;
  }

  // Sair
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Adicione aqui o login com Facebook, se necessário
}
