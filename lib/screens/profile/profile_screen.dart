import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Aquí se cargan datos reales desde Firestore una vez integrado
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 12),
            const Text('Nombre de usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('correo@ejemplo.com'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {
            }, child: const Text('Editar perfil')),
          ]),
        ),
      ),
    );
  }
}
