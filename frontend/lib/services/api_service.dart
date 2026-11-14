
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'secure_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio dio;

  final SecureStorageService _storage = SecureStorageService();

  Future<String?>? _refreshFuture;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_URL'),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.obtenerAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        onError: (error, handler) async {
          final request = error.requestOptions;

          final esRutaAutenticacion =
              request.path.contains('/api/auth/login') ||
              request.path.contains('/api/auth/refresh');

          final yaSeReintento =
              request.extra['retry'] == true;

          if (error.response?.statusCode != 401 ||
              esRutaAutenticacion ||
              yaSeReintento) {
            handler.next(error);
            return;
          }

          try {
            final nuevoToken = await _renovarToken();

            if (nuevoToken == null) {
              handler.next(error);
              return;
            }

            request.headers['Authorization'] =
                'Bearer $nuevoToken';

            request.extra['retry'] = true;

            final response = await dio.fetch(request);

            handler.resolve(response);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
  }

  // Renovar el token de acceso
  Future<String?> _renovarToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final future = _realizarRenovacion();
    _refreshFuture = future;

    try {
      return await future;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _realizarRenovacion() async {
    final refreshToken = await _storage.obtenerRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _storage.eliminarTokens();
      return null;
    }

    // Cliente independiente para evitar repetir el interceptor
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_URL'),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final response = await refreshDio.post(
        '/api/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      final datos = Map<String, dynamic>.from(response.data);

      final nuevoAccessToken =
          datos['access_token'] as String;

      final nuevoRefreshToken =
          datos['refresh_token'] as String;

      await _storage.guardarTokens(
        accessToken: nuevoAccessToken,
        refreshToken: nuevoRefreshToken,
      );

      return nuevoAccessToken;
    } on DioException {
      await _storage.eliminarTokens();
      return null;
    } catch (_) {
      await _storage.eliminarTokens();
      return null;
    }
  }
}
