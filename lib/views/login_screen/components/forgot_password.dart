import 'package:flutter/material.dart';
import 'package:tcc_projeto/shared/firebase_authentication.dart'; // Certifique-se de que o caminho esteja correto

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController _emailController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _isSubmitting = false;
    String _message = '';

    // Função para lidar com o envio do e-mail
    Future<void> _submitForgotPassword() async {
      if (!_formKey.currentState!.validate()) return;

      // Inicia o estado de submissão
      _isSubmitting = true;

      try {
        // Chama o método resetPassword da FirebaseAuthentication para enviar o e-mail de redefinição
        await FirebaseAuthentication.resetPassword(_emailController.text);
        _message =
            'E-mail de recuperação enviado com sucesso! Verifique sua caixa de entrada.';
      } catch (e) {
        _message = 'Erro ao enviar e-mail. Tente novamente.';
      } finally {
        _isSubmitting = false;
        // Atualiza o estado da UI com a mensagem
        if (context.mounted) {
          // Exibe a mensagem no diálogo
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Recuperação de Senha'),
                content: Text(_message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              );
            },
          );
        }
      }
    }

    // Exibe o modal com o campo de e-mail
    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar ao tocar fora do modal
      builder: (BuildContext context) {
        return AlertDialog(
          title: Stack(
            children: [
              const Text('Recuperar Senha'),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o modal
                  },
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Digite seu e-mail para receber o link de redefinição de senha.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForgotPassword,
                        child: const Text('Enviar link'),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showForgotPasswordDialog(context), // Abre o modal ao clicar
      child: const Text(
        'Esqueceu a senha?',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1CB0F6),
        ),
      ),
    );
  }
}
