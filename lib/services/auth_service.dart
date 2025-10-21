import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  final String baseUrl = dotenv.env['URL_API']!;

  //! login se encarga de autenticar al usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      //* especifica el tipo de contenido que se va a enviar
      //* el servidor espera recibir un JSON
      headers: {'Content-Type': 'application/json'},
      //* convierte el objeto a JSON
      //* se envia el email y la contraseña al servidor
      //* el servidor devuelve un token y el usuario
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        //! shared_preferences se encarga de guardar el token y el usuario
        //! en el dispositivo del usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
      } catch (e) {
        debugPrint('Error al guardar token en SharedPreferences: $e');
      }

      return {'success': true, 'user': User.fromJson(data['user'])};
    } else {
      //* si el servidor devuelve un error, se convierte el objeto a JSON
      //* y se devuelve el mensaje de error
      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Error en login'};
    }
  }

  //! register se encarga de registrar al usuario
  //* se le pasa el nombre, email y contraseña al servidor
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Error en registro',
        'errors': data['errors'],
      };
    }
  }

  //! getUser se encarga de obtener el usuario
  //* se obtiene el usuario de SharedPreferences
  Future<User?> getUser() async {
    try {
      //* se obtiene el usuario de SharedPreferences
      //* se convierte el objeto a JSON
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        return User.fromJson(jsonDecode(userStr));
      }
    } catch (e) {
      debugPrint('Error al obtener SharedPreferences: $e');
    }
    return null;
  }

  //! getToken se encarga de obtener el token
  //* se obtiene el token de SharedPreferences
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error al obtener token: $e');
      return null;
    }
  }

  //! isLoggedIn se encarga de verificar si el usuario está logueado
  //* se verifica si el token existe en SharedPreferences
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
