import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:huella/models/reto_model.dart';

class RetosService {
  final String baseUrl = 'http://localhost:4000/api'; // Cambia según tu configuración
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Obtener todos los retos
  Future<List<Reto>> obtenerRetos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Reto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar retos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener retos por categoría
  Future<List<Reto>> obtenerRetosPorCategoria(String categoria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retos/categoria/$categoria'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Reto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar retos por categoría');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener reto diario
  Future<RetoUsuario> obtenerRetoDiario() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retos/diario'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RetoUsuario.fromJson(data);
      } else {
        throw Exception('Error al cargar reto diario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Completar reto
  Future<bool> completarReto(int retoUsuarioId, {String? notas}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/retos/$retoUsuarioId/completar'),
        headers: _headers,
        body: json.encode({'notas': notas}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al completar reto: $e');
    }
  }

  // Obtener historial
  Future<List<RetoUsuario>> obtenerHistorial() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retos/historial'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RetoUsuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar historial');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/retos/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estadísticas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}