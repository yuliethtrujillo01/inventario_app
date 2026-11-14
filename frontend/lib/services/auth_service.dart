
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'secure_storage_service.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_URL'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final SecureStorageService _storage = SecureStorageService();

  // Iniciar sesión
  Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'correo': correo,
          'password': password,
        },
      );

      final datos = Map<String, dynamic>.from(response.data);

      // Guardar los tokens de forma segura
      await _storage.guardarTokens(
        accessToken: datos['access_token'],
        refreshToken: datos['refresh_token'],
      );

      return datos;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Correo o contraseña incorrectos.');
      }

      if (e.response?.statusCode == 422) {
        throw Exception('Verifica los datos ingresados.');
      }

      throw Exception(
        'No fue posible iniciar sesión: ${e.message}',
      );
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _storage.eliminarTokens();
  }

  // Consultar si existe una sesión guardada
  Future<bool> tieneSesion() async {
    return await _storage.tieneSesion();
  }
}
