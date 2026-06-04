import 'package:water_ledger/core/domain/enums/user_role.dart';

/// Configuración de control de acceso del router.
///
/// Se separa de `app_router.dart` para que las reglas sean fáciles de auditar
/// y mantener cuando se sumen rutas nuevas (módulo 4.1.4.4 / 4.1.4.6).

/// Paths que pueden visitarse sin sesión iniciada.
/// Incluye splash, login y todo el flujo de registro (con sus success screens).
const Set<String> _publicPaths = {
  '/splash',
  '/login',
  '/register',
  '/forgot-password',
  '/retail-register',
  '/corporate-onboarding',
  '/auditor-register',
  '/certifier-register',
  '/insurance-register',
  '/retail-register-success',
  '/company-register-success',
  '/auditor-register-success',
  '/certifier-register-success',
  '/insurance-register-success',
  '/register-success',
};

/// Paths a los que NO debería volver un usuario ya logueado
/// (si entra, lo pateamos a /home → dispatcher → su dashboard).
const Set<String> _authEntryPaths = {
  '/login',
  '/register',
};

/// Mapa de paths → roles autorizados.
/// Si un path no está acá, se asume que cualquier rol autenticado puede entrar.
const Map<String, Set<UserRole>> _roleAccessMap = {
  // Módulo de emisión (4.2) — solo empresa emisora
  '/credit-issuance': {UserRole.company},
  '/submission-confirmation': {UserRole.company},
  '/request-tracking': {UserRole.company},   // fallback (sin param)

  // Módulo de auditoría — solo auditor
  '/auditor': {UserRole.auditor},
  '/auditor-request-detail': {UserRole.auditor},

  // Módulo de certificación — solo certifier
  '/certifier': {UserRole.certifier},
  '/certifier-request-detail': {UserRole.certifier},

  // Módulo de seguros — solo insurer
  '/insurer': {UserRole.insurer},
  '/insurer-request-detail': {UserRole.insurer},

  // Módulo admin (4.6) — solo admin
  '/admin-dashboard': {UserRole.admin},
};

bool isPublicPath(String path) => _publicPaths.contains(path);

bool isAuthEntryPath(String path) => _authEntryPaths.contains(path);

/// ¿El rol tiene acceso a la ruta?
/// Maneja también paths con parámetros dinámicos como /admin-pending-detail/:uid.
bool roleHasAccess(UserRole role, String path) {
  // Sub-rutas de admin con parámetros — todas requieren admin
  if (path.startsWith('/admin-pending-detail/') ||
      path.startsWith('/admin-')) {
    return role == UserRole.admin;
  }

  // Sub-rutas de auditor con parámetros
  if (path.startsWith('/auditor-request-detail/')) {
    return role == UserRole.auditor;
  }

  // Sub-rutas de certifier con parámetros
  if (path.startsWith('/certifier-request-detail/')) {
    return role == UserRole.certifier;
  }

  // Sub-rutas de insurer con parámetros
  if (path.startsWith('/insurer-request-detail/')) {
    return role == UserRole.insurer;
  }

  // Sub-rutas de company con parámetros
  if (path.startsWith('/request-tracking/')) {
    return role == UserRole.company || role == UserRole.issuer;
  }

  final allowed = _roleAccessMap[path];
  // Si no está mapeada, cualquier rol logueado puede entrar (ej: /home)
  return allowed == null || allowed.contains(role);
}
