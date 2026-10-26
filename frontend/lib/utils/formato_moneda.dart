import 'package:intl/intl.dart';

class FormatoMoneda {
  static final NumberFormat _formatoNumero =
      NumberFormat.decimalPattern('es_CO');

  static String pesos(num valor) {
    return '\$${_formatoNumero.format(valor)}';
  }
}