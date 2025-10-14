import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:4000/api/auth';
  bool isLoading = false;

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  // ✅ Headers automáticos con token + LOGS
  Map<String, String> get authHeaders {
    print("🔍 Generando headers...");
    if (_token != null) {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };
      print("✅ Headers con token: $headers");
      return headers;
    }
    print("⚠️ Headers SIN token");
    return {
      'Content-Type': 'application/json',
    };
  }

  /// 🧠 LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    print("🔄 Iniciando login con email: $email");

    try {
      final url = Uri.parse('$_baseUrl/login');
      print("📡 URL Login: $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print("📩 Respuesta del backend: ${response.body}");
      print("📌 Status code: ${response.statusCode}");

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        print("✅ Login exitoso, datos recibidos: $decodedData");

        // ✅ Guardar token y datos del usuario
        _token = decodedData['token'];
        _user = decodedData['user'];

        print("🔐 Token guardado: $_token");
        print("👤 Usuario guardado: $_user");

        notifyListeners();
        return {'ok': true, 'data': decodedData};
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print("❌ Error en login: ${errorData['message']}");
        return {
          'ok': false,
          'message': errorData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("❌ Error de conexión: $e");
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// 🧾 REGISTER
  Future<Map<String, dynamic>> register(String email, String password) async {
    print("📝 Intentando registro con email: $email");
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("📩 Respuesta de registro: ${response.body}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Registro exitoso");
        return {'ok': true, 'message': 'Registro exitoso'};
      } else {
        print("❌ Error en registro: ${response.body}");
        return {'ok': false, 'message': 'Error: ${response.body}'};
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      return {'ok': false, 'message': e.toString()};
    }
  }

  /// 🚪 LOGOUT
  void logout() {
    print("🚪 Cerrando sesión...");
    print("🔐 Token eliminado: $_token");
    _token = null;
    _user = null;
    notifyListeners();
  }
}
