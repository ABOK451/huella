import 'package:flutter/material.dart';

class RetosScreen extends StatelessWidget {
  const RetosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final retos = [
      {'title': 'Reciclar plástico', 'desc': 'Separa plástico y deposítalo en el contenedor correcto.'},
      {'title': 'Ahorra agua', 'desc': 'Cierra el grifo mientras te cepillas los dientes.'},
      {'title': 'Camina o usa bici', 'desc': 'Evita el auto para distancias cortas.'},
    ];
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: retos.length,
        itemBuilder: (_, i) {
          final r = retos[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.celebration),
              title: Text(r['title']!),
              subtitle: Text(r['desc']!),
              trailing: ElevatedButton(onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reto marcado (simulado)')));
              }, child: const Text('Completar')),
            ),
          );
        },
      ),
    );
  }
}
