class Validators {
  static final RegExp _emailRegExp =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    if (!_emailRegExp.hasMatch(email)) {
      return 'Ingrese un correo electrónico válido.';
    }
    return null;
  }

  static String? validarPassword(String? valor, {int minimo = 6}) {
    final password = valor ?? '';
    if (password.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (password.length < minimo) {
      return 'La contraseña debe tener al menos $minimo caracteres.';
    }
    return null;
  }

  static String? validarCampoObligatorio(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombreCampo es obligatorio.';
    }
    return null;
  }

  static String? validarTelefono(String? valor) {
    final telefono = valor?.trim() ?? '';
    if (telefono.isEmpty) {
      return 'El teléfono es obligatorio.';
    }
    if (telefono.length < 9 || int.tryParse(telefono) == null) {
      return 'Ingrese un teléfono válido (mínimo 9 dígitos).';
    }
    return null;
  }
}
