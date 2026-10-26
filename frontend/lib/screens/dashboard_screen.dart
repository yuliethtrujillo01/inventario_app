
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto_model.dart';
import '../services/producto_service.dart';
import '../utils/formato_moneda.dart';
import '../widgets/app_bottom_navigation.dart';
import 'producto_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const azulOscuro = Color(0xFF122B50);
  static const azul = Color(0xFF2367CD);
  static const verde = Color(0xFF109883);
  static const fondo = Color(0xFFF3F6FB);

  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    _productosFuture = _service.obtenerProductos();
  }

  void _actualizar() {
    setState(() {
      _cargarProductos();
    });
  }

  Future<void> _nuevoProducto() async {
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

  Widget _indicador({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    required Color fondoIcono,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: azulOscuro.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: fondoIcono,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: azulOscuro,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF65768D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accesoRapido({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
    required Color fondoIcono,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fondoIcono,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: color, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: azulOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF65768D),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA8B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(double valorInventario) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
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
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de control',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestiona tus productos de forma inteligente',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFD0E0F3),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Valor total del inventario',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDDECFB),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      color: Color(0xFF66E0C3),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    FormatoMoneda.pesos(valorInventario),
                    style: const TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Valor actual de tus existencias',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB8D0EC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: azulOscuro,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.inventory_2_outlined),
            SizedBox(width: 10),
            Text(
              'InventarioApp',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar inventario',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onProductCreated: _actualizar,
      ),
      body: FutureBuilder<List<Producto>>(
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
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No se pudo cargar el inventario',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _actualizar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final productos = snapshot.data ?? [];

          final totalProductos = productos.length;

          final totalUnidades = productos.fold<int>(
            0,
            (suma, producto) => suma + producto.cantidad,
          );

          final valorInventario = productos.fold<double>(
            0,
            (suma, producto) => suma + producto.valorTotal,
          );

          return RefreshIndicator(
            onRefresh: () async {
              _actualizar();
              await _productosFuture;
            },
            child: ListView(
              children: [
                _encabezado(valorInventario),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del inventario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: azulOscuro,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _indicador(
                              titulo: 'Productos registrados',
                              valor: '$totalProductos',
                              icono: Icons.inventory_2_outlined,
                              color: azul,
                              fondoIcono:
                                  const Color(0xFFE3EEFE),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _indicador(
                              titulo: 'Unidades disponibles',
                              valor: '$totalUnidades',
                              icono: Icons.warehouse_outlined,
                              color: verde,
                              fondoIcono:
                                  const Color(0xFFDDF7EE),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 27),

                      const Text(
                        'Accesos rápidos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: azulOscuro,
                        ),
                      ),
                      const SizedBox(height: 13),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _accesoRapido(
                              titulo: 'Gestionar productos',
                              subtitulo:
                                  'Consultar, editar y eliminar',
                              icono: Icons.inventory_2_outlined,
                              color: azul,
                              fondoIcono:
                                  const Color(0xFFE3EEFE),
                              onTap: () {
                                context.go('/productos');
                              },
                            ),
                            const Divider(
                              height: 1,
                              indent: 15,
                              endIndent: 15,
                            ),
                            _accesoRapido(
                              titulo: 'Agregar producto',
                              subtitulo:
                                  'Registrar en el inventario',
                              icono: Icons.add_circle_outline,
                              color: verde,
                              fondoIcono:
                                  const Color(0xFFDDF7EE),
                              onTap: _nuevoProducto,
                            ),
                          ],
                        ),
                      ),

                      if (productos.isEmpty) ...[
                        const SizedBox(height: 22),
                        const Center(
                          child: Text(
                            'No hay productos registrados',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
