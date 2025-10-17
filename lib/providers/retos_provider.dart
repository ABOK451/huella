import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RetosProvider extends ChangeNotifier {
  final String baseUrl = 'http://localhost:4000/api'; // OK para navegador

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

  /// COMPLETAR RETO
  Future<bool> completarReto({
    required String retoId,
    required String token, // ✅ Token requerido
    File? evidencia,
    Map<String, dynamic>? datosExtra,
  }) async {
    if (token == null) return false;

    try {
      final url = Uri.parse('$baseUrl/$retoId/completar');
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['datosExtra'] = jsonEncode(datosExtra ?? {});

      if (evidencia != null) {
        request.files.add(await http.MultipartFile.fromPath('evidencia', evidencia.path));
      }

      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error completar reto: $e');
      return false;
    }
  }

  /// OBTENER HISTORIAL DE RETOS
  Future<List<Map<String, dynamic>>?> obtenerHistorial({required String token}) async {
    if (token == null) return null;

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

  /// OBTENER ESTADÍSTICAS
  Future<Map<String, dynamic>?> obtenerEstadisticas({required String token}) async {
    if (token == null) return null;

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

}