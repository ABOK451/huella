import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final posts = [
      {'user': 'María', 'text': 'Reciclamos en mi colonia hoy!'},
      {'user': 'Luis', 'text': 'Hice bici al trabajo, me siento genial.'},
    ];
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (_, i) {
          final p = posts[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(p['user']!),
              subtitle: Text(p['text']!),
            ),
          );
        },
      ),
    );
  }
}
