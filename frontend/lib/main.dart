

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/login_screen.dart';
import 'services/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const InventarioApp());
}

final SecureStorageService storage = SecureStorageService();

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // Verificar si existe una sesión guardada
    final tieneSesion = await storage.tieneSesion();

    final estaEnLogin = state.matchedLocation == '/login';

    // Si no hay sesión, enviar al inicio de sesión
    if (!tieneSesion && !estaEnLogin) {
      return '/login';
    }

    // Si ya hay sesión, evitar volver al login
    if (tieneSesion && estaEnLogin) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/productos',
      builder: (context, state) => const ProductosScreen(),
    ),
  ],
);

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InventarioApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
