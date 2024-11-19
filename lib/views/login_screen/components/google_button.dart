import 'package:flutter/material.dart';

class GoogleButton extends StatefulWidget {
  final VoidCallback
      onPressed; // Adiciona o callback para o botão de login via Google

  const GoogleButton({required this.onPressed, super.key});

  @override
  State<StatefulWidget> createState() {
    return GoogleButtonState();
  }
}

class GoogleButtonState extends State<GoogleButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 3, color: Colors.grey.shade400),
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ), // Usa o callback passado
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/google-icon.png',
                height: 20,
              ),
              Text(
                ' GOOGLE',
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
