import 'package:cafeteria_app/screens/login_screen.dart';
import 'package:cafeteria_app/screens/pantalla_cafeteria.dart';
import 'package:cafeteria_app/services/session_service.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.email,
    required this.nombreCompleto,
  });

  final String email;
  final String nombreCompleto;

  Future<void> _cerrarSesion(BuildContext context) async {
    await SessionService.instance.cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _irACafeteria(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaCafeteria()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Bienvenida'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.waving_hand, size: 80, color: Colors.deepOrange.shade700),
              const SizedBox(height: 24),
              const Text(
                '¡Bienvenido/a!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                nombreCompleto,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.email, color: Colors.deepOrangeAccent),
                  title: const Text('Correo registrado'),
                  subtitle: Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _irACafeteria(context),
                  icon: const Icon(Icons.local_cafe),
                  label: const Text('Ir a la Cafetería'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    foregroundColor: Colors.white,
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
