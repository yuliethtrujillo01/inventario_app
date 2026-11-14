
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Guardar los tokens después del inicio de sesión
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  // Obtener el token de acceso
  Future<String?> obtenerAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Obtener el token de actualización
  Future<String?> obtenerRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Eliminar los tokens al cerrar sesión
  Future<void> eliminarTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Verificar si existe una sesión guardada
  Future<bool> tieneSesion() async {
    final token = await obtenerAccessToken();
    return token != null && token.isNotEmpty;
  }
}
