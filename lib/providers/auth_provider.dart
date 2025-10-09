import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:4000/api/auth';
  bool isLoading = false;

  Future<Map<String, dynamic>> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/login');

      print('📤 Intentando login con: $email'); // Para debug

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('📡 Status code: ${response.statusCode}'); // Para debug
      print('📡 Response body: ${response.body}'); // Para debug

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        return {'ok': true, 'data': decodedData};
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'ok': false,
          'message': errorData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      print('🚨 Error en login: $e'); // Para debug
      isLoading = false;
      notifyListeners();
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'ok': true, 'message': 'Registro exitoso'};
      } else {
        return {'ok': false, 'message': 'Error: ${response.body}'};
      }
    } catch (e) {
      return {'ok': false, 'message': e.toString()};
    }
  }
}
