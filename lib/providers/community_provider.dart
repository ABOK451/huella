import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommunityProvider extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:4000/api/community';
  bool isLoading = false;
  List<dynamic> _posts = [];

  List<dynamic> get posts => _posts;

  /// Obtener todas las publicaciones
  Future<void> fetchPosts() async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _posts = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetchPosts: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// Crear nueva publicación
  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String message, // cambio de "contenido" a "message"
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final newPost = json.decode(response.body);
        _posts.insert(0, newPost);
        notifyListeners();
        return {'ok': true, 'data': newPost};
      } else {
        return {
          'ok': false,
          'message': json.decode(response.body)['message'] ??
              'Error al crear publicación',
        };
      }
    } catch (e) {
      return {'ok': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Dar like a una publicación
  Future<void> likePost(String postId) async {
    try {
      final url = Uri.parse('$_baseUrl/$postId/like');
      final response = await http.patch(url); // PATCH en vez de POST

      if (response.statusCode == 200) {
        final updatedPost = json.decode(response.body);
        final index = _posts.indexWhere((p) => p['_id'] == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error likePost: $e');
    }
  }

  /// Eliminar publicación
  Future<void> deletePost(String postId) async {
    try {
      final url = Uri.parse('$_baseUrl/$postId');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        _posts.removeWhere((p) => p['_id'] == postId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deletePost: $e');
    }
  }
}
