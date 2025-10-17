import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart'; // NECESARIO para kIsWeb
import 'dart:typed_data'; // NECESARIO para Uint8List (mostrar imagen en Web)

import 'package:huella/models/reto_model.dart';
import 'package:huella/providers/retos_provider.dart';
import 'package:huella/providers/auth_provider.dart'; // Para obtener el token

class RetoDetalleScreen extends StatefulWidget {
  final Reto reto;
  final String tipo; // tipo del reto: 'foto', 'checklist', 'ubicacion'
  final List<String>? tareas; // para checklist
  final double? latitud; // para ubicación
  final double? longitud;

  const RetoDetalleScreen({
    super.key,
    required this.reto,
    this.tipo = 'foto',
    this.tareas,
    this.latitud,
    this.longitud,
  });

  @override
  State<RetoDetalleScreen> createState() => _RetoDetalleScreenState();
}

class _RetoDetalleScreenState extends State<RetoDetalleScreen> {
  // 🚩 CAMBIO: Usamos XFile para compatibilidad Web
  XFile? _imagenEvidencia; 
  List<Map<String, dynamic>> _tareas = [];
  bool _ubicacionVerificada = false;

  @override
  void initState() {
    super.initState();
    if (widget.tipo == 'checklist' && widget.tareas != null) {
      _tareas = widget.tareas!
          .map((t) => {'texto': t, 'completado': false})
          .toList();
    }
  }

  // --- Seleccionar imagen para reto tipo "foto"
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    // NOTA: En Web, source: ImageSource.camera puede no funcionar sin HTTPS
    final picked = await picker.pickImage(source: ImageSource.camera); 
    if (picked != null) {
      setState(() {
        _imagenEvidencia = picked; // 🚩 Guardamos XFile
      });
    }
  }

  // --- Verificar ubicación para reto tipo "ubicacion"
  Future<void> _verificarUbicacion() async {
    // Código de Geolocator... (no requiere cambios para el error actual)
    LocationPermission permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) return;

    Position pos = await Geolocator.getCurrentPosition();
    double distancia = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      widget.latitud ?? 0,
      widget.longitud ?? 0,
    );

    if (distancia < 100) {
      setState(() => _ubicacionVerificada = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación verificada ✅')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No estás en el lugar correcto ❌')),
      );
    }
  }

  // --- Completar reto
  Future<void> _completarReto() async {
    final retosProvider = Provider.of<RetosProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token; // 👈 Obteniendo el token

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Token de autenticación no encontrado.')),
      );
      return;
    }

    // Validaciones según tipo de reto
    if (widget.tipo == 'foto' && _imagenEvidencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sube una foto antes de completar')),
      );
      return;
    }

    if (widget.tipo == 'checklist') {
      final completadas = _tareas.where((t) => t['completado'] == true).length;
      if (completadas < _tareas.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todas las tareas primero')),
        );
        return;
      }
    }

    if (widget.tipo == 'ubicacion' && !_ubicacionVerificada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifica tu ubicación primero')),
      );
      return;
    }
    
    // 🚩 MANEJO CONDICIONAL DEL ARCHIVO DE EVIDENCIA
    File? evidenciaFile;
    // Solo creamos el dart:io.File si NO es web
    if (!kIsWeb && _imagenEvidencia != null) { 
      evidenciaFile = File(_imagenEvidencia!.path);
    } 
    // NOTA: Si necesitas subir archivos en la Web, se requerirá una modificación al backend 
    // y al RetosProvider para aceptar bytes de Uint8List, ya que File no existe en Web. 
    // Para esta corrección, solo se permite la subida en móvil.

    // Llamada al backend
    final ok = await retosProvider.completarReto(
      retoId: widget.reto.id.toString(),
      token: token, // 👈 INYECTANDO EL TOKEN
      evidencia: evidenciaFile, // 👈 Usamos evidenciaFile (será null en web)
      datosExtra: {
        'tipo': widget.tipo,
        'tareas': _tareas,
        'ubicacion': _ubicacionVerificada,
      },
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reto completado con éxito! 🎉')),
      );
      Navigator.pop(context, true);
    } else if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al completar el reto.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = widget.tipo;

    return Scaffold(
      appBar: AppBar(title: Text(widget.reto.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(widget.reto.descripcion),
            const SizedBox(height: 20),

            if (tipo == 'foto') _buildFotoReto(),
            if (tipo == 'checklist') _buildChecklist(),
            if (tipo == 'ubicacion') _buildUbicacion(),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como completado'),
              onPressed: _completarReto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoReto() {
    return Column(
      children: [
        if (_imagenEvidencia != null)
          Container(
            height: 180,
            alignment: Alignment.center,
            child: Builder(
              builder: (context) {
                if (kIsWeb) {
                  // 🚩 SOLUCIÓN WEB: Usamos Image.memory
                  return FutureBuilder<Uint8List>(
                    future: _imagenEvidencia!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover, height: 180);
                      }
                      return const CircularProgressIndicator();
                    },
                  );
                } else {
                  // 🚩 SOLUCIÓN MOBILE/Desktop: Usamos Image.file
                  return Image.file(
                    File(_imagenEvidencia!.path),
                    height: 180, 
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
          )
        else
          const Text('Sube una foto como evidencia'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tomar foto'),
          onPressed: _seleccionarImagen,
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: _tareas.map((t) {
        return CheckboxListTile(
          title: Text(t['texto']),
          value: t['completado'],
          onChanged: (val) => setState(() => t['completado'] = val),
        );
      }).toList(),
    );
  }

  Widget _buildUbicacion() {
    return Column(
      children: [
        Text(
          _ubicacionVerificada
              ? 'Ubicación verificada ✅'
              : 'Verifica que estás en el lugar indicado.',
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.location_on),
          label: const Text('Verificar ubicación'),
          onPressed: _verificarUbicacion,
        ),
      ],
    );
  }
}