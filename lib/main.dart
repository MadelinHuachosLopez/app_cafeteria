import 'package:cafeteria_app/screens/login_screen.dart';
import 'package:cafeteria_app/screens/welcome_screen.dart';
import 'package:cafeteria_app/services/session_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  runApp(const MiCafeteriaApp());
}

class MiCafeteriaApp extends StatelessWidget {
  const MiCafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MI CAFETERIA APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  Future<Widget> _resolverPantallaInicial() async {
    final haySesion = await SessionService.instance.haySesionActiva();

    if (haySesion) {
      final email = await SessionService.instance.obtenerEmailSesion();
      final nombre = await SessionService.instance.obtenerNombreSesion();

      if (email != null && nombre != null) {
        return WelcomeScreen(email: email, nombreCompleto: nombre);
      }
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolverPantallaInicial(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
            ),
          );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return const LoginScreen();
      },
    );
  }
}
