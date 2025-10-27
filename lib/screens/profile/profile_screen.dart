import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/retos_provider.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _retosCompletados = [];
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final retosProv = Provider.of<RetosProvider>(context, listen: false);
    final token = auth.token;

    if (token != null) {
      final historial = await retosProv.obtenerHistorial(token: token);
      final stats = await retosProv.obtenerEstadisticas(token: token);

      if (mounted) {
        setState(() {
          _retosCompletados = historial ?? [];
          _estadisticas = stats;
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4CAF50);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFF81C784),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?['name'] ?? 'Sin nombre',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?['email'] ?? 'Sin correo',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Puntos y logros
                    _buildEstadisticasCard(),

                    const SizedBox(height: 20),

                    // Retos completados
                    _buildRetosCompletados(),

                    const SizedBox(height: 30),

                    // Botón cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              OnboardingScreen.routeName,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 2),
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEstadisticasCard() {
  final impacto = _estadisticas?['impacto'] ?? {};
  final puntos = impacto['puntosGanados'] ?? 0;
  final co2 = impacto['co2Ahorrado'] ?? '0';
  final agua = impacto['aguaAhorrada'] ?? '0';
  final porcentaje = _estadisticas?['porcentajeCompletado'] ?? '0';

  // Calcular racha de retos completados consecutivos
  int racha = 0;
  for (var reto in _retosCompletados) {
    if (reto['completado'] == true) {
      racha++;
    } else {
      break;
    }
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estadísticas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Puntos: $puntos', style: const TextStyle(fontSize: 16)),
            Text('Completado: $porcentaje%', style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('CO2 ahorrado: $co2 kg', style: const TextStyle(fontSize: 16)),
            Text('Agua ahorrada: $agua L', style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Text('Racha de retos completados: $racha', style: const TextStyle(fontSize: 16)),
      ],
    ),
  );
}

Widget _buildRetosCompletados() {
  if (_retosCompletados.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('Aún no has completado retos.'),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Retos Completados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ..._retosCompletados.map((r) {
        final reto = r['reto'] ?? {}; // ✅ Alias correcto del backend
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(reto['titulo'] ?? 'Reto sin título'),
            subtitle: Text('Puntos: ${reto['puntos'] ?? 0}'),
            trailing: r['completado'] == true
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.pending, color: Colors.grey),
          ),
        );
      }).toList(),
    ],
  );
}

}
