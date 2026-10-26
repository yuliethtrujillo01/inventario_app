
import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/producto_service.dart';
import '../utils/formato_moneda.dart';
import '../widgets/app_bottom_navigation.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() =>
      _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  static const Color azulOscuro = Color(0xFF122B50);
  static const Color azul = Color(0xFF2367CD);
  static const Color verde = Color(0xFF109883);
  static const Color fondo = Color(0xFFF3F6FB);

  final ProductoService _service = ProductoService();
  final TextEditingController _buscarController =
      TextEditingController();

  late Future<List<Producto>> _productosFuture;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  // GET: cargar productos desde FastAPI
  void _cargarProductos() {
    _productosFuture = _service.obtenerProductos();
  }

  void _actualizar() {
    setState(() {
      _cargarProductos();
    });
  }

  // POST: abrir formulario para crear producto
  Future<void> _registrarProducto() async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductoFormScreen(),
      ),
    );

    if (!mounted) return;

    if (registrado == true) {
      _actualizar();
    }
  }

  // PUT: abrir formulario de edición
  Future<void> _editarProducto(Producto producto) async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoFormScreen(
          producto: producto,
        ),
      ),
    );

    if (!mounted) return;

    if (actualizado == true) {
      _actualizar();
    }
  }

  // DELETE: eliminar producto con confirmación
  Future<void> _eliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Deseas eliminar "${producto.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _service.eliminarProducto(producto.id);

      if (!mounted) return;

      _actualizar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Producto eliminado correctamente',
          ),
          backgroundColor: verde,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // GET por ID: consultar detalle directamente
  Future<void> _mostrarDetalle(Producto producto) async {
    final futuroDetalle =
        _service.obtenerProductoPorId(producto.id);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Detalle del producto'),
        content: FutureBuilder<Producto>(
          future: futuroDetalle,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'No se pudo consultar el producto.\n'
                '${snapshot.error}',
              );
            }

            final detalle = snapshot.data;

            if (detalle == null) {
              return const Text('Producto no encontrado');
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EEFE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: azul,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    detalle.nombre,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _filaDetalle('ID', '${detalle.id}'),
                  _filaDetalle('Código', detalle.codigo),
                  _filaDetalle(
                    'Categoría',
                    detalle.categoria,
                  ),
                  _filaDetalle(
                    'Precio',
                    FormatoMoneda.pesos(detalle.precio),
                  ),
                  _filaDetalle(
                    'Cantidad',
                    '${detalle.cantidad} unidades',
                  ),
                  _filaDetalle(
                    'Descripción',
                    detalle.descripcion?.isNotEmpty == true
                        ? detalle.descripcion!
                        : 'Sin descripción',
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Valor en inventario',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FormatoMoneda.pesos(
                      detalle.valorTotal,
                    ),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _editarProducto(detalle);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: azul,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _eliminarProducto(detalle);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _filaDetalle(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: azulOscuro,
            ),
          ),
        ],
      ),
    );
  }

  // Encabezado y buscador
  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF122B50),
            Color(0xFF205188),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestiona tu inventario',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consulta y administra tus productos',
            style: TextStyle(
              color: Color(0xFFD0E0F3),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _buscarController,
            onChanged: (texto) {
              setState(() {
                _busqueda = texto.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar nombre, código o categoría',
              prefixIcon: const Icon(
                Icons.search,
                color: azul,
              ),
              suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _buscarController.clear();
                        setState(() {
                          _busqueda = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta visual de un producto
  Widget _tarjetaProducto(Producto producto) {
    final bajoStock = producto.cantidad <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: azulOscuro.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _mostrarDetalle(producto),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3EEFE),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: azul,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: azulOscuro,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${producto.codigo} · '
                            '${producto.categoria}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const Divider(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRECIO UNITARIO',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            FormatoMoneda.pesos(
                              producto.precio,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: azulOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'DISPONIBILIDAD',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${producto.cantidad} unidades',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: bajoStock
                                ? Colors.deepOrange
                                : verde,
                          ),
                        ),
                        if (bajoStock)
                          const Text(
                            'Existencias bajas',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.deepOrange,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text(
          'InventarioApp',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: azulOscuro,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Actualizar productos',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onProductCreated: _actualizar,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarProducto,
        backgroundColor: verde,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: Column(
        children: [
          _encabezado(),
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: _productosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_outlined,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudieron cargar los productos',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _actualizar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final todos = snapshot.data ?? [];

                final productos = todos.where((producto) {
                  final texto =
                      '${producto.nombre} '
                      '${producto.codigo} '
                      '${producto.categoria}'
                          .toLowerCase();

                  return texto.contains(_busqueda);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18, 20, 18, 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: azul,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              '${productos.length} de '
                              '${todos.length} productos',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulOscuro,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: productos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    todos.isEmpty
                                        ? 'No hay productos registrados'
                                        : 'No se encontraron productos',
                                  ),
                                  if (todos.isEmpty)
                                    TextButton(
                                      onPressed: _registrarProducto,
                                      child: const Text(
                                        'Registrar producto',
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                final nuevos =
                                    _service.obtenerProductos();

                                final datos = await nuevos;

                                if (!mounted) return;

                                setState(() {
                                  _productosFuture =
                                      Future.value(datos);
                                });
                              },
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  16, 0, 16, 100,
                                ),
                                itemCount: productos.length,
                                itemBuilder: (context, index) {
                                  return _tarjetaProducto(
                                    productos[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
