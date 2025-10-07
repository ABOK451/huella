import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';
import 'package:huella/core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // simula llamada
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de autenticación')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => isValidEmail(v ?? '') ? null : 'Correo inválido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtl,
                decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => (v != null && v.length >= 6) ? null : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: const Color(0xFF4CAF50)),
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                child: const Text('¿No tienes cuenta? Regístrate'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
