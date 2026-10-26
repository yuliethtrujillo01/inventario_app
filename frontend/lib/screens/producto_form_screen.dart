
import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({
    super.key,
    this.producto,
  });

  @override
  State<ProductoFormScreen> createState() =>
      _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  static const Color azulOscuro = Color(0xFF122B50);
  static const Color azul = Color(0xFF2367CD);
  static const Color verde = Color(0xFF109883);
  static const Color fondo = Color(0xFFF3F6FB);

  final _formKey = GlobalKey<FormState>();
  final _service = ProductoService();

  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _categoriaController = TextEditingController();

  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    if (producto != null) {
      _nombreController.text = producto.nombre;
      _codigoController.text = producto.codigo;
      _descripcionController.text = producto.descripcion ?? '';
      _precioController.text = producto.precio.toStringAsFixed(2);
      _cantidadController.text = producto.cantidad.toString();
      _categoriaController.text = producto.categoria;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (_guardando || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _guardando = true;
    });

    try {
      final nombre = _nombreController.text.trim();
      final codigo = _codigoController.text.trim();
      final descripcion = _descripcionController.text.trim();
      final categoria = _categoriaController.text.trim();

      final precio = double.parse(
        _precioController.text.trim().replaceAll(',', '.'),
      );

      final cantidad = int.parse(
        _cantidadController.text.trim(),
      );

      if (_esEdicion) {
        await _service.actualizarProducto(
          id: widget.producto!.id,
          nombre: nombre,
          codigo: codigo,
          descripcion: descripcion,
          precio: precio,
          cantidad: cantidad,
          categoria: categoria,
        );
      } else {
        await _service.crearProducto(
          nombre: nombre,
          codigo: codigo,
          descripcion: descripcion,
          precio: precio,
          cantidad: cantidad,
          categoria: categoria,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar el producto: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
    bool opcional = false,
    bool esPrecio = false,
    bool esCantidad = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        enabled: !_guardando,
        style: const TextStyle(
          color: azulOscuro,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono, color: azul),
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0E7F0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0E7F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: azul,
              width: 1.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
        ),
        validator: (valor) {
          final texto = valor?.trim() ?? '';

          if (texto.isEmpty) {
            return opcional
                ? null
                : 'Este campo es obligatorio';
          }

          if (esPrecio) {
            final numero = double.tryParse(
              texto.replaceAll(',', '.'),
            );

            if (numero == null ||
                !numero.isFinite ||
                numero < 0) {
              return 'Ingresa un precio válido';
            }

            if ((numero * 100 -
                        (numero * 100).round())
                    .abs() > 0.000001) {
              return 'Máximo dos decimales';
            }

            if (numero > 9999999999.99) {
              return 'El precio supera el límite permitido';
            }
          }

          if (esCantidad) {
            final numero = int.tryParse(texto);

            if (numero == null || numero < 0) {
              return 'Ingresa una cantidad entera válida';
            }
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_guardando,
      child: Scaffold(
        backgroundColor: fondo,

        appBar: AppBar(
          title: Text(
            _esEdicion
                ? 'Editar producto'
                : 'Nuevo producto',
          ),
          backgroundColor: azulOscuro,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // Encabezado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  23, 15, 23, 35,
                ),
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
                    bottom: Radius.circular(26),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _esEdicion
                          ? Icons.edit_note_rounded
                          : Icons.add_box_outlined,
                      color: const Color(0xFF66E0C3),
                      size: 38,
                    ),

                    const SizedBox(height: 13),

                    Text(
                      _esEdicion
                          ? 'Actualizar producto'
                          : 'Registrar nuevo producto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _esEdicion
                          ? 'Modifica los datos del producto '
                            'en tu inventario.'
                          : 'Completa los datos para agregar '
                            'un producto a tu inventario.',
                      style: const TextStyle(
                        color: Color(0xFFD0E0F3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulario
              Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: azulOscuro.withValues(
                                alpha: 0.05,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: azul,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Información del producto',
                                    style: TextStyle(
                                      color: azulOscuro,
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            _campo(
                              etiqueta: 'Nombre del producto',
                              controller: _nombreController,
                              icono: Icons.inventory_outlined,
                            ),

                            _campo(
                              etiqueta: 'Código único',
                              controller: _codigoController,
                              icono: Icons.qr_code,
                            ),

                            _campo(
                              etiqueta: 'Descripción (opcional)',
                              controller:
                                  _descripcionController,
                              icono: Icons.description_outlined,
                              opcional: true,
                              maxLines: 2,
                            ),

                            _campo(
                              etiqueta: 'Precio unitario',
                              controller: _precioController,
                              icono: Icons.attach_money,
                              tipo:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              esPrecio: true,
                            ),

                            _campo(
                              etiqueta: 'Cantidad disponible',
                              controller: _cantidadController,
                              icono: Icons.numbers,
                              tipo: TextInputType.number,
                              esCantidad: true,
                            ),

                            _campo(
                              etiqueta: 'Categoría',
                              controller: _categoriaController,
                              icono: Icons.category_outlined,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón guardar o actualizar
                      SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                              _guardando ? null : _guardarProducto,
                          icon: _guardando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _esEdicion
                                      ? Icons.check_circle_outline
                                      : Icons.save_outlined,
                                ),
                          label: Text(
                            _guardando
                                ? 'Guardando...'
                                : _esEdicion
                                    ? 'Actualizar producto'
                                    : 'Guardar producto',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _esEdicion ? azul : verde,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF94A3B8),
                            disabledForegroundColor:
                                Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      OutlinedButton(
                        onPressed: _guardando
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          side: const BorderSide(
                            color: Color(0xFFD8E1ED),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
