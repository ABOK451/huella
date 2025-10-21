import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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

      // ✅ Guardar token en memoria
      _token = decodedData['token'];

      // ✅ Guardar datos del usuario (SIN token)
      _user = decodedData['user'];
      print("👤 Usuario guardado en memoria: $_user");

      // 🧠 Guardar usuario localmente (sin token)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user));
      print("💾 Usuario guardado en localStorage (SharedPreferences)");

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
Future<Map<String, dynamic>> register(String name, String email, String password) async {
  print("📝 Intentando registro con email: $email y nombre: $name");
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    print("📩 Respuesta de registro: ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      print("✅ Registro exitoso, datos recibidos: $decodedData");

      // Guardar usuario en memoria (sin token)
      _user = decodedData['user'];
      notifyListeners();

      return {'ok': true, 'data': decodedData};
    } else {
      print("❌ Error en registro: ${response.body}");
      return {'ok': false, 'message': 'Error: ${response.body}'};
    }
  } catch (e) {
    print("❌ Error de conexión: $e");
    return {'ok': false, 'message': e.toString()};
  }
}



  /// 💾 Guardar usuario en localStorage (sin token)
  Future<void> saveUserToLocalStorage(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  /// 📂 Cargar usuario desde localStorage
  Future<void> loadUserFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = jsonDecode(userData);
      notifyListeners();
    }
  }

  /// 🧹 Eliminar usuario del almacenamiento
  Future<void> clearUserFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  /// 🚪 LOGOUT
Future<void> logout() async {
  print("🚪 Cerrando sesión...");

  try {
    if (_token != null) {
      final url = Uri.parse('$_baseUrl/logout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      print("📩 Respuesta logout: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("⚠️ Error al cerrar sesión en el backend: $e");
  }

  // 🔐 Siempre limpia localmente
  await clearUserFromLocalStorage();
  _token = null;
  _user = null;
  notifyListeners();
}

}
