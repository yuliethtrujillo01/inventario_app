
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_flutter/main.dart';

void main() {
  test('La aplicación InventarioApp está definida', () {
    const app = InventarioApp();

    expect(app, isA<InventarioApp>());
  });
}
