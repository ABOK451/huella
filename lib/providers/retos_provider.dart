import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RetosProvider extends ChangeNotifier {
  final String baseUrl = 'http://localhost:4000/api';

  // --- OBTENER RETOS DIARIOS
  Future<List<Map<String, dynamic>>?> obtenerRetoDiario({required String token}) async {
    final url = Uri.parse('$baseUrl/retos/diario');
    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint('Error obtener reto diario: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error conectar con backend: $e');
      return null;
    }
  }

  // --- COMPLETAR RETO
  Future<bool> completarReto({
  required String retoUsuarioId, // ✅ ID de RetoUsuario
  required String token,
  File? evidencia,               // Móvil
  Uint8List? evidenciaWeb,       // Web
  Map<String, dynamic>? datosExtra,
}) async {
  if (token.isEmpty) return false;

  try {
    final url = Uri.parse('$baseUrl/retos/$retoUsuarioId/completar');

    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['datosExtra'] = jsonEncode(datosExtra ?? {})
      ..fields['notas'] = 'He completado el reto';


    // Evidencia: móvil o web
    if (!kIsWeb && evidencia != null) {
      request.files.add(await http.MultipartFile.fromPath('evidencia', evidencia.path));
    } else if (kIsWeb && evidenciaWeb != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'evidencia',
        evidenciaWeb,
        filename: 'evidencia.png',
      ));
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      debugPrint('Error completarReto Backend: ${response.statusCode} - $respStr');
      return false;
    }
  } catch (e) {
    debugPrint('Error completarReto: $e');
    return false;
  }
}

  // --- HISTORIAL DE RETOS
  Future<List<Map<String, dynamic>>?> obtenerHistorial({required String token}) async {
    if (token.isEmpty) return null;

    final url = Uri.parse('$baseUrl/retos/historial');
    try {
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      } else {
        debugPrint('Error obtener historial: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error historial: $e');
      return null;
    }
  }

  // --- ESTADÍSTICAS
  Future<Map<String, dynamic>?> obtenerEstadisticas({required String token}) async {
    if (token.isEmpty) return null;

    final url = Uri.parse('$baseUrl/retos/estadisticas');
    try {
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        debugPrint('Error estadísticas: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error estadísticas: $e');
      return null;
    }
  }

  // --- OBTENER RETOS POR CATEGORÍA
  Future<List<Map<String, dynamic>>?> obtenerRetosPorCategoria({
    required String token,
    required String categoria,
  }) async {
    final url = Uri.parse('$baseUrl/retos/categoria/$categoria');
    try {
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint('Error obtener retos por categoría: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error conectar con backend: $e');
      return null;
    }
  }
}
