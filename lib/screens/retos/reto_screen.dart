import 'package:flutter/material.dart';
import 'package:huella/models/reto_model.dart';
import 'package:huella/providers/auth_provider.dart';
import 'package:huella/providers/retos_provider.dart';
import 'package:provider/provider.dart';
import 'reto_detalle_screen.dart';

class RetoScreen extends StatefulWidget {
  const RetoScreen({super.key});

  @override
  State<RetoScreen> createState() => _RetoScreenState();
}

class _RetoScreenState extends State<RetoScreen> {
  List<Reto> retosDiarios = []; 
  bool cargando = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    cargarReto();
  }

  Future<void> cargarReto() async {
    setState(() {
      cargando = true;
      errorMsg = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final retosProvider = Provider.of<RetosProvider>(context, listen: false);

    // 1. Obtener el token del AuthProvider
    final token = authProvider.token; 

    if (token == null) {
      setState(() {
        errorMsg = 'Usuario no autenticado. Inicie sesión de nuevo.';
        cargando = false;
      });
      return;
    }

    try {
      final data = await retosProvider.obtenerRetoDiario(token: token); 

        if (data != null && data.isNotEmpty) {
            final List<Reto> nuevosRetos = data.map((map) => Reto.fromJson(map)).toList();
            
            setState(() {
                retosDiarios = nuevosRetos; 
                cargando = false;
            });
        } else {
            setState(() {
                errorMsg = 'No se pudieron cargar retos diarios. La API devolvió vacío o error.';
                cargando = false;
            });
        }
    } catch (e) {
      setState(() {
        errorMsg = 'Error al conectar con el servidor: $e';
        cargando = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return  Scaffold(
        appBar: AppBar(title: Text('Cargando Retos...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text(errorMsg!,
              style: const TextStyle(fontSize: 16, color: Colors.red)),
        ),
      );
    }

    if (retosDiarios.isEmpty) {
      return  Scaffold(
        appBar: AppBar(title:Text('Retos Diarios')),
        body: Center(child: Text('¡Excelente! No hay retos pendientes para hoy.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Retos Diarios')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: retosDiarios.length,
        itemBuilder: (context, index) {
          final reto = retosDiarios[index]; 
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.star, color: _getColorByDificultad(reto.dificultad)),
              title: Text(reto.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(reto.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                // Navegación a la pantalla de detalle del reto seleccionado
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RetoDetalleScreen(reto: reto),
                  ),
                );
                // Si el reto fue completado (result == true), recarga la lista
                if (result == true) cargarReto();
              },
            ),
          );
        },
      ),
    );
  }

  Color _getColorByDificultad(String dificultad) {
    switch (dificultad.toLowerCase()) {
      case 'facil':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
