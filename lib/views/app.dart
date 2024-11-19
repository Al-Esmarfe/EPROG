import 'package:tcc_projeto/views/choose_language_screen/choose_language_screen.dart';
import 'package:tcc_projeto/views/login_screen/login_screen.dart';
import 'package:tcc_projeto/views/welcome_screen/components/sing_up_button.dart';
import 'package:tcc_projeto/views/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen/home_screen.dart';

class MyEPROD extends StatelessWidget {
  const MyEPROD({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/choose-language': (context) => const ChooseLanguageScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'C-language',
      // theme: ThemeData(
      //   scaffoldBackgroundColor: Colors.blueGrey,
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
    );
  }
}
