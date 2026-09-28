import 'package:cafeteria_app/database/database_helper.dart';
import 'package:cafeteria_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _tipoUsuario;
  bool _aceptaTerminos = false;
  bool _ocultarPassword = true;
  bool _cargando = false;

  final List<String> _tiposUsuario = [
    'Administrador',
    'Empleado',
    'Cliente',
  ];

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un tipo de usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      await DatabaseHelper.instance.registrarUsuario(
        nombreCompleto: _nombreController.text,
        email: _emailController.text,
        telefono: _telefonoController.text,
        password: _passwordController.text,
        tipoUsuario: _tipoUsuario!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Inicie sesión con su cuenta.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } on DatabaseException catch (e) {
      if (!mounted) return;
      final mensaje = e.isUniqueConstraintError()
          ? 'El correo electrónico ya está registrado.'
          : 'No se pudo completar el registro.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add, size: 64, color: Colors.deepOrangeAccent),
              const SizedBox(height: 8),
              const Text(
                'Crear cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) =>
                    Validators.validarCampoObligatorio(valor, 'El nombre completo'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validarEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validarTelefono,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _ocultarPassword = !_ocultarPassword);
                    },
                  ),
                ),
                validator: Validators.validarPassword,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                decoration: const InputDecoration(
                  labelText: 'Tipo de usuario',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _tiposUsuario
                    .map(
                      (tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ),
                    )
                    .toList(),
                onChanged: (valor) => setState(() => _tipoUsuario = valor),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _aceptaTerminos,
                onChanged: (valor) {
                  setState(() => _aceptaTerminos = valor ?? false);
                },
                title: const Text('Acepto los términos y condiciones'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.deepOrangeAccent,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargando ? null : _registrarUsuario,
                icon: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.app_registration),
                label: Text(_cargando ? 'Registrando...' : 'Registrarse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
