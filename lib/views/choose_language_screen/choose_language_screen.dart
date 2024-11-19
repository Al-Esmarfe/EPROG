import 'package:tcc_projeto/views/choose_language_screen/components/app_bar.dart';
import 'package:tcc_projeto/views/choose_language_screen/components/continue_button.dart';
import 'package:flutter/material.dart';

class ChooseLanguageScreen extends StatelessWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChooseLanguageAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'What do you want to learn?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'For English speakers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 2.5,
                    color: const Color(0xFFE5E5E5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Center(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ContinueButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
