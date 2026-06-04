import 'package:firebase_auth/firebase_auth.dart';

/// Excepción de auth con mensaje listo para mostrar al usuario.
/// El repository la lanza después de mapear códigos de FirebaseAuthException,
/// así la UI no tiene que conocer detalles de Firebase.
class AuthException implements Exception {
  final String message;
  /// Código original de Firebase (útil para tracking / logs). Puede ser null
  /// si el error no vino de FirebaseAuth.
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Mapea un código de FirebaseAuthException al mensaje user-facing en español.
/// Si no reconoce el código, devuelve el message original o un fallback.
AuthException mapFirebaseAuthException(FirebaseAuthException e) {
  final msg = switch (e.code) {
    'invalid-email' => 'El email tiene un formato inválido.',
    'user-disabled' => 'Esta cuenta fue deshabilitada.',
    'user-not-found' => 'No existe una cuenta con ese email.',
    'wrong-password' => 'Contraseña incorrecta.',
    // Firebase agrupa user-not-found + wrong-password en este código nuevo
    // por motivos de seguridad (evitar enumeración de cuentas).
    'invalid-credential' => 'Email o contraseña incorrectos.',
    'too-many-requests' =>
      'Demasiados intentos fallidos. Esperá unos minutos antes de reintentar.',
    'network-request-failed' =>
      'Sin conexión. Verificá tu internet y reintentá.',
    'email-already-in-use' => 'Ya existe una cuenta registrada con ese email.',
    'weak-password' =>
      'La contraseña es muy débil. Usá al menos 6 caracteres.',
    'operation-not-allowed' =>
      'Este tipo de cuenta no está habilitado en este momento.',
    'missing-email' => 'Ingresá un email.',
    'missing-password' => 'Ingresá una contraseña.',
    'requires-recent-login' =>
      'Por seguridad, volvé a iniciar sesión y reintentá la operación.',
    _ => e.message ?? 'Error de autenticación (${e.code}).',
  };
  return AuthException(msg, code: e.code);
}
