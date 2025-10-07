import 'package:flutter/material.dart';
import 'package:huella/screens/comunity/comunity_screen.dart';
import 'package:huella/screens/profile/profile_screen.dart';
import 'retos_screen.dart';
import 'impacto_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _current = 0;
  final _pages = const [HomeContent(), RetosScreen(), ImpactoScreen(), CommunityScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _current = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Retos'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Impacto'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Comunidad'),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Huella+')),
            ListTile(title: const Text('Perfil'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            ListTile(title: const Text('Cerrar sesión'), onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Hola, bienvenido a Huella+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: const [
              Text('Reto del día', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Usa una botella reutilizable hoy en lugar de comprar botellas plásticas.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Marcar como completado'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50))),
      ]),
    );
  }
}
