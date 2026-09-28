import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const String _claveEmail = 'usuario_email';
  static const String _claveNombre = 'usuario_nombre';

  Future<void> guardarSesion({
    required String email,
    required String nombreCompleto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveEmail, email);
    await prefs.setString(_claveNombre, nombreCompleto);
  }

  Future<String?> obtenerEmailSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveEmail);
  }

  Future<String?> obtenerNombreSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveNombre);
  }

  Future<bool> haySesionActiva() async {
    final email = await obtenerEmailSesion();
    return email != null && email.isNotEmpty;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveEmail);
    await prefs.remove(_claveNombre);
  }
}
