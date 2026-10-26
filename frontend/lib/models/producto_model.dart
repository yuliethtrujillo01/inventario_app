
class Producto {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      descripcion: json['descripcion'] as String?,
      precio: double.parse(json['precio'].toString()),
      cantidad: (json['cantidad'] as num).toInt(),
      categoria: json['categoria'] as String,
    );
  }

  double get valorTotal => precio * cantidad;
}
