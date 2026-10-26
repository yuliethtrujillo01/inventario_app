
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/producto_form_screen.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onProductCreated;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onProductCreated,
  });

  Future<void> _abrirFormulario(BuildContext context) async {
    final registrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductoFormScreen(),
      ),
    );

    if (registrado == true && context.mounted) {
      onProductCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF122B50)
                .withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFE3EEFE),
          selectedIndex: currentIndex,
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                if (currentIndex != 0) {
                  context.go('/');
                }
                break;

              case 1:
                if (currentIndex != 1) {
                  context.go('/productos');
                }
                break;

              case 2:
                _abrirFormulario(context);
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: Color(0xFF2367CD),
              ),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(
                Icons.inventory_2,
                color: Color(0xFF2367CD),
              ),
              label: 'Productos',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.add_circle_outline,
                color: Color(0xFF109883),
              ),
              selectedIcon: Icon(
                Icons.add_circle,
                color: Color(0xFF109883),
              ),
              label: 'Nuevo',
            ),
          ],
        ),
      ),
    );
  }
}
