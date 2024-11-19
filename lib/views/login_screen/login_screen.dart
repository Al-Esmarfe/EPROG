import 'package:flutter/material.dart';
import 'package:tcc_projeto/shared/firebase_authentication.dart';
import 'package:tcc_projeto/views/login_screen/components/facebook_button.dart';
import 'package:tcc_projeto/views/login_screen/components/forgot_password.dart';
import 'package:tcc_projeto/views/login_screen/components/google_button.dart';
import 'package:tcc_projeto/views/login_screen/components/login_button.dart';
import 'package:tcc_projeto/views/login_screen/components/policy_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'components/app_bar.dart';
import 'components/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final FirebaseAuthentication auth;
  String loginMessage = '';

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      auth = FirebaseAuthentication();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LoginAppBar(),
      body: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: InputField(emailController, passwordController),
            ),
            LoginButton(
              emailController: emailController,
              passwordController: passwordController,
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  User? user = await auth.signInWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (user != null) {
                    setState(() {
                      loginMessage = "Login realizado com sucesso!";
                    });
                    Navigator.pushNamed(context, '/home');
                  } else {
                    setState(() {
                      loginMessage =
                          "Erro ao realizar login. Verifique suas credenciais.";
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              loginMessage,
              style: const TextStyle(color: Colors.red),
            ),
            const ForgotPassword(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
