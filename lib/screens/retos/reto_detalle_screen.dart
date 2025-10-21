import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:huella/models/reto_model.dart';
import 'package:huella/providers/retos_provider.dart';
import 'package:huella/providers/auth_provider.dart';

class RetoDetalleScreen extends StatefulWidget {
  final Reto reto;
  final String tipo;
  final List<String>? tareas;
  final double? latitud;
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
  XFile? _imagenEvidencia;
  Uint8List? _imagenWeb;
  List<Map<String, dynamic>> _tareas = [];
  bool _ubicacionVerificada = false;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();

    if (widget.tipo == 'checklist' && widget.tareas != null) {
      _tareas = widget.tareas!
          .map((t) => {'texto': t, 'completado': false})
          .toList();
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _imagenEvidencia = picked;
      });

      if (kIsWeb) {
        _imagenWeb = await picked.readAsBytes();
      }
    }
  }

  Future<void> _verificarUbicacion() async {
    setState(() => _procesando = true);

    try {
      LocationPermission permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (mounted) {
          _mostrarSnackbar(
            'Necesitas dar permisos de ubicación',
            Icons.error_outline,
            Colors.red,
          );
        }
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      double distancia = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        widget.latitud ?? 0,
        widget.longitud ?? 0,
      );

      if (distancia < 100) {
        setState(() => _ubicacionVerificada = true);
        if (mounted) {
          _mostrarSnackbar(
            'Ubicación verificada correctamente',
            Icons.check_circle,
            Colors.green,
          );
        }
      } else {
        if (mounted) {
          _mostrarSnackbar(
            'Debes estar a menos de 100m del lugar',
            Icons.location_off,
            Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackbar(
          'Error al obtener ubicación',
          Icons.error_outline,
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  void _mostrarSnackbar(String mensaje, IconData icono, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icono, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _completarReto() async {
    final retosProvider = Provider.of<RetosProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      _mostrarSnackbar(
        'Error: Token no encontrado',
        Icons.error_outline,
        Colors.red,
      );
      return;
    }

    // Validaciones por tipo
    if (widget.tipo == 'foto' && _imagenEvidencia == null) {
      _mostrarSnackbar(
        'Sube una foto antes de completar',
        Icons.photo_camera,
        Colors.orange,
      );
      return;
    }

    if (widget.tipo == 'checklist') {
      final completadas = _tareas.where((t) => t['completado'] == true).length;
      if (completadas < _tareas.length) {
        _mostrarSnackbar(
          'Completa todas las tareas primero',
          Icons.checklist,
          Colors.orange,
        );
        return;
      }
    }

    if (widget.tipo == 'ubicacion' && !_ubicacionVerificada) {
      _mostrarSnackbar(
        'Verifica tu ubicación primero',
        Icons.location_on,
        Colors.orange,
      );
      return;
    }

    setState(() => _procesando = true);

    final ok = await retosProvider.completarReto(
      retoUsuarioId: widget.reto.id.toString(),
      token: token,
      evidencia: !kIsWeb
          ? (_imagenEvidencia != null ? File(_imagenEvidencia!.path) : null)
          : null,
      evidenciaWeb: kIsWeb ? _imagenWeb : null,
      datosExtra: {
        'tipo': widget.tipo,
        'tareas': _tareas,
        'ubicacion': _ubicacionVerificada,
      },
    );

    setState(() => _procesando = false);

    if (ok && mounted) {
      _mostrarSnackbar(
        '¡Reto completado con éxito!',
        Icons.celebration,
        Colors.green,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else if (!ok && mounted) {
      _mostrarSnackbar(
        'Error al completar el reto',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getDificultadConfig(widget.reto.dificultad);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              _buildHeader(config),

              // Contenido scrolleable
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tarjeta de información del reto
                    _buildInfoCard(config),
                    const SizedBox(height: 24),

                    // Contenido según tipo
                    if (widget.tipo == 'foto') _buildFotoReto(),
                    if (widget.tipo == 'checklist') _buildChecklist(),
                    if (widget.tipo == 'ubicacion') _buildUbicacion(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Botón flotante para completar
      floatingActionButton: _buildFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config['gradient'] as List<Color>,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Botón de regreso
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              // Badge de dificultad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config['icon'] as IconData,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.reto.dificultad,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Título
          Text(
            widget.reto.titulo,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Badge de puntos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFFF9800), size: 20),
                const SizedBox(width: 8),
                Text(
                  '+${widget.reto.puntos} puntos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: config['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.reto.descripcion,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF424242),
              height: 1.5,
            ),
          ),
          if (widget.reto.categoria.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.category_rounded,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.reto.categoria,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFotoReto() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Evidencia Fotográfica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_imagenEvidencia != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: kIsWeb
                      ? (_imagenWeb != null
                          ? Image.memory(
                              _imagenWeb!,
                              fit: BoxFit.cover,
                            )
                          : const Center(child: CircularProgressIndicator()))
                      : Image.file(
                          File(_imagenEvidencia!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Toma una foto como evidencia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_imagenEvidencia != null ? 'Cambiar foto' : 'Tomar foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildChecklist() {
    final completadas = _tareas.where((t) => t['completado'] == true).length;
    final progreso = _tareas.isNotEmpty ? completadas / _tareas.length : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF9C27B0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lista de Tareas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completadas/${_tareas.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              ),
            ),
            const SizedBox(height: 20),
            // Tareas
            ..._tareas.asMap().entries.map((entry) {
              final index = entry.key;
              final tarea = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: tarea['completado']
                        ? const Color(0xFF9C27B0).withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tarea['completado']
                          ? const Color(0xFF9C27B0).withValues(alpha: 0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: tarea['completado'],
                    onChanged: (val) {
                      setState(() => tarea['completado'] = val);
                    },
                    title: Text(
                      tarea['texto'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: tarea['completado']
                            ? const Color(0xFF9C27B0)
                            : const Color(0xFF424242),
                        decoration: tarea['completado']
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tarea['completado']
                            ? const Color(0xFF9C27B0)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: tarea['completado']
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    activeColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
  }

  Widget _buildUbicacion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFFF5722),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Verificación de Ubicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _ubicacionVerificada
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _ubicacionVerificada
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _ubicacionVerificada
                        ? Icons.check_circle_rounded
                        : Icons.location_searching_rounded,
                    size: 64,
                    color: _ubicacionVerificada
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _ubicacionVerificada
                        ? 'Ubicación verificada correctamente'
                        : 'Debes estar en el lugar indicado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _ubicacionVerificada
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ubicacionVerificada
                        ? '¡Perfecto! Puedes completar el reto'
                        : 'Verifica tu ubicación para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _procesando ? null : _verificarUbicacion,
                icon: _procesando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        _ubicacionVerificada
                            ? Icons.refresh_rounded
                            : Icons.my_location_rounded,
                      ),
                label: Text(
                  _procesando
                      ? 'Verificando...'
                      : _ubicacionVerificada
                          ? 'Verificar nuevamente'
                          : 'Verificar ubicación',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildFloatingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _procesando ? null : _completarReto,
        icon: _procesando
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_rounded, size: 28),
        label: Text(
          _procesando ? 'Completando...' : 'Completar Reto',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Map<String, dynamic> _getDificultadConfig(String dificultad) {
    switch (dificultad.toLowerCase()) {
      case 'facil':
        return {
          'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
          'icon': Icons.eco_rounded,
        };
      case 'medio':
      case 'media':
        return {
          'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
          'icon': Icons.local_fire_department_rounded,
        };
      case 'dificil':
        return {
          'gradient': [const Color(0xFFE53935), const Color(0xFFEF5350)],
          'icon': Icons.bolt_rounded,
        };
      default:
        return {
          'gradient': [const Color(0xFF757575), const Color(0xFF9E9E9E)],
          'icon': Icons.flag_rounded,
        };
    }
  }
}