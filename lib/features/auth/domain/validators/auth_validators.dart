/// Validadores puros para formularios de autenticación.
/// Cada función devuelve `null` si el valor es válido, o un `String` con el
/// mensaje de error listo para mostrar al usuario (en español).
///
/// Se mantienen libres de Flutter para poder usarse tanto desde la UI como
/// desde tests unitarios.
class AuthValidators {
  AuthValidators._();

  // Regex razonable para emails (no se busca cumplir RFC al 100%, sólo
  // descartar valores claramente inválidos antes de enviar a Firebase).
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // CUIT argentino: 2 dígitos + 8 dígitos + 1 dígito. Acepta con o sin guiones.
  static final _cuitRegex = RegExp(r'^\d{2}-?\d{8}-?\d$');

  // Teléfono mínimo: al menos 7 dígitos, opcionalmente con +, espacios, guiones, paréntesis.
  static final _phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,}$');

  // DNI argentino: 7 u 8 dígitos. Los puntos separadores se quitan antes de validar.
  static final _dniRegex = RegExp(r'^\d{7,8}$');

  /// Email obligatorio + formato razonable.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá un email.';
    if (!_emailRegex.hasMatch(v)) return 'El email tiene un formato inválido.';
    return null;
  }

  /// Password obligatoria, mínimo 6 caracteres (regla de Firebase Auth).
  /// `requireStrong` exige además al menos un número y una letra.
  static String? password(String? value, {bool requireStrong = false}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Ingresá una contraseña.';
    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    if (requireStrong) {
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
      final hasDigit = RegExp(r'\d').hasMatch(v);
      if (!hasLetter || !hasDigit) {
        return 'La contraseña debe combinar letras y números.';
      }
    }
    return null;
  }

  /// Verifica que la confirmación matchee con la password original.
  static String? passwordConfirm(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirmá la contraseña.';
    if (value != original) return 'Las contraseñas no coinciden.';
    return null;
  }

  /// Campo de texto obligatorio. Pasale el nombre del campo para que el
  /// mensaje sea claro ("Ingresá el nombre", "Ingresá el CUIT", etc.).
  static String? required(String? value, String fieldLabel) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá $fieldLabel.';
    return null;
  }

  /// CUIT argentino (XX-XXXXXXXX-X o sin guiones).
  static String? cuit(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá el CUIT.';
    if (!_cuitRegex.hasMatch(v)) {
      return 'El CUIT tiene un formato inválido (XX-XXXXXXXX-X).';
    }
    return null;
  }

  /// Teléfono con al menos 7 dígitos (admite formatos internacionales).
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá un teléfono.';
    if (!_phoneRegex.hasMatch(v)) {
      return 'El teléfono tiene un formato inválido.';
    }
    return null;
  }

  /// DNI argentino (7 u 8 dígitos, con o sin puntos separadores de miles).
  static String? dni(String? value) {
    // Quitamos los puntos para aceptar tanto "12345678" como "12.345.678".
    final v = (value ?? '').replaceAll('.', '').trim();
    if (v.isEmpty) return 'Ingresá el DNI.';
    if (!_dniRegex.hasMatch(v)) {
      return 'El DNI tiene un formato inválido (7 u 8 dígitos).';
    }
    return null;
  }

  /// Helper: corre una lista de validadores en orden y devuelve el primer
  /// error encontrado, o null si todos pasaron.
  /// Útil para validar un formulario completo y mostrar sólo el primer error.
  static String? firstError(List<String? Function()> validators) {
    for (final v in validators) {
      final result = v();
      if (result != null) return result;
    }
    return null;
  }
}
