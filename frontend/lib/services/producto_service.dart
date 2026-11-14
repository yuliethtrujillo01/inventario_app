
import 'package:dio/dio.dart';

import '../models/producto_model.dart';
import 'api_service.dart';

class ProductoService {
  final Dio _dio = ApiService().dio;

  // GET: listar todos los productos
  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await _dio.get('/api/productos');

      final datos = response.data as List<dynamic>;

      return datos.map((item) {
        return Producto.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        'Error al consultar los productos: ${e.message}',
      );
    }
  }

  // GET: consultar un producto por ID
  Future<Producto> obtenerProductoPorId(int id) async {
    try {
      final response = await _dio.get('/api/productos/$id');

      return Producto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Producto no encontrado.');
      }

      throw Exception(
        'Error al consultar el producto: ${e.message}',
      );
    }
  }

  // POST: registrar un producto
  Future<void> crearProducto({
    required String nombre,
    required String codigo,
    required String descripcion,
    required double precio,
    required int cantidad,
    required String categoria,
  }) async {
    try {
      await _dio.post(
        '/api/productos',
        data: {
          'nombre': nombre,
          'codigo': codigo,
          'descripcion': descripcion,
          'precio': precio,
          'cantidad': cantidad,
          'categoria': categoria,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception(
          'Datos inválidos o código de producto repetido.',
        );
      }

      throw Exception(
        'Error al registrar el producto: ${e.message}',
      );
    }
  }

  // PUT: actualizar un producto
  Future<void> actualizarProducto({
    required int id,
    required String nombre,
    required String codigo,
    required String descripcion,
    required double precio,
    required int cantidad,
    required String categoria,
  }) async {
    try {
      await _dio.put(
        '/api/productos/$id',
        data: {
          'nombre': nombre,
          'codigo': codigo,
          'descripcion': descripcion,
          'precio': precio,
          'cantidad': cantidad,
          'categoria': categoria,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('El producto no existe.');
      }

      if (e.response?.statusCode == 422) {
        throw Exception(
          'Datos inválidos o código de producto repetido.',
        );
      }

      throw Exception(
        'Error al actualizar el producto: ${e.message}',
      );
    }
  }

  // DELETE: eliminar un producto
  Future<void> eliminarProducto(int id) async {
    try {
      await _dio.delete('/api/productos/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('El producto ya no existe.');
      }

      throw Exception(
        'Error al eliminar el producto: ${e.message}',
      );
    }
  }
}