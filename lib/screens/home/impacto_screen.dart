import 'package:flutter/material.dart';

class ImpactoScreen extends StatelessWidget {
  const ImpactoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Placeholder de métricas
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('Tu Impacto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(title: const Text('Agua ahorrada'), subtitle: const Text('12 litros')),
          ),
          const SizedBox(height: 8),
          Card(child: ListTile(title: const Text('CO₂ reducido'), subtitle: const Text('1.2 kg'))),
          const SizedBox(height: 8),
          Card(child: ListTile(title: const Text('Residuos reciclados'), subtitle: const Text('3 kg'))),
        ]),
      ),
    );
  }
}
