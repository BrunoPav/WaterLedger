import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/config/router/go_router_refresh_stream.dart';
import 'package:water_ledger/core/config/router/route_access.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_request_detail_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/documentation_screen.dart';
import 'package:water_ledger/features/certifier/presentation/screens/certifier_requests_screen.dart';
import 'package:water_ledger/features/certifier/presentation/screens/certifier_request_detail_screen.dart';
import 'package:water_ledger/features/insurer/presentation/screens/insurer_requests_screen.dart';
import 'package:water_ledger/features/insurer/presentation/screens/insurer_request_detail_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/auditor_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/auditor_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/certifier_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/certifier_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/insurance_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_dashboard_screen.dart';
// Import de la pantalla de seed comentado al borrarse la vista — el usuario ya creó su admin en Firestore:
// import 'package:water_ledger/core/presentation/screens/admin/admin_seed_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/pending_approvals_list_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/pending_request_detail_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_requests_list_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_request_detail_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_valuations_list_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_valuation_detail_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/company_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/corporate_onboarding_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/retail_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/retail_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/login_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/register_screen.dart';
import 'package:water_ledger/core/presentation/screens/splash_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/credit_issuance_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/roadmap_editor_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/submission_confirmation_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/request_tracking_screen.dart';
import 'package:water_ledger/features/dashboards/presentation/screens/home_dispatcher.dart';
import 'package:water_ledger/features/profiles/presentation/screens/profile_dispatcher.dart';
import 'package:water_ledger/features/profiles/presentation/screens/profile_edit_screen.dart';
import 'package:water_ledger/features/issuer/presentation/screen/issuing_company_screen.dart';

/// Provider del router con guard de auth y rol.
/// El guard:
///  - Patea a /login si la ruta es protegida y no hay sesión
///  - Patea a /home si la ruta es de auth (login/register) y ya hay sesión
///  - Patea a /home si el rol del user no tiene acceso a la ruta
/// El `refreshListenable` hace que el redirect se re-evalúe automáticamente
/// cuando cambia el estado de autenticación de Firebase.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authRepositoryProvider).authStateChanges;

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final path = state.matchedLocation;

      // /splash siempre se deja pasar — el SplashScreen maneja su propia
      // navegación según el estado de la sesión.
      if (path == '/splash') return null;

      // Mientras la sesión todavía está cargando, no redirigir.
      if (session.isLoading) return null;

      final user = session.value;
      final isPublic = isPublicPath(path);

      // Path público
      if (isPublic) {
        // Si ya hay sesión activa y va a /login o /register, patear a /home
        if (user != null && isAuthEntryPath(path)) return '/home';
        return null;
      }

      // Path protegido sin sesión: a login
      if (user == null) return '/login';

      // Path protegido con sesión: validar rol
      if (!roleHasAccess(user.role, path)) {
        return '/home';
      }

      return null;
    },
    routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/corporate-onboarding', builder: (context, state) => const CorporateOnboardingScreen()),
    GoRoute(path: '/company-register-success', builder: (context, state) => const CompanyRegisterSuccessScreen()),
    GoRoute(path: '/retail-register', builder: (context, state) => const RetailRegisterScreen()),
    GoRoute(path: '/auditor-register', builder: (context, state) => const AuditorRegisterScreen()),
    GoRoute(path: '/auditor-register-success', builder: (context, state) => const AuditorRegisterSuccessScreen()),
    GoRoute(path: '/certifier-register', builder: (context, state) => const CertifierRegisterScreen()),
    GoRoute(path: '/certifier-register-success', builder: (context, state) => const CertifierRegisterSuccessScreen()),
    GoRoute(path: '/insurance-register', builder: (context, state) => const InsuranceRegisterScreen()),
    GoRoute(path: '/insurance-register-success', builder: (context, state) => const RegisterSuccessScreen()),
    GoRoute(path: '/register-success', builder: (context, state) => const RegisterSuccessScreen()),
    // ---- Admin (4.6 Gestión del Administrador) ---- //
    // Ruta /admin-seed comentada al borrarse la pantalla de seed — el usuario ya creó su admin.
    // El método registerAdmin sigue disponible en AuthRepository por si más adelante se necesita
    // habilitar creación de admins desde otra pantalla (ej. un panel super-admin).
    // GoRoute(path: '/admin-seed', builder: (context, state) => const AdminSeedScreen()),
    GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(
      path: '/admin-pending-approvals',
      builder: (context, state) => const PendingApprovalsListScreen(),
    ),
    GoRoute(
      path: '/admin-pending-detail/:uid',
      builder: (context, state) => PendingRequestDetailScreen(
        uid: state.pathParameters['uid']!,
      ),
    ),
    GoRoute(
      path: '/admin-credit-requests',
      builder: (context, state) => const AdminRequestsListScreen(),
    ),
    GoRoute(
      path: '/admin-request-detail/:requestId',
      builder: (context, state) => AdminRequestDetailScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
    GoRoute(
      path: '/admin-valuations',
      builder: (context, state) => const AdminValuationsListScreen(),
    ),
    GoRoute(
      path: '/admin-valuation-detail/:requestId',
      builder: (context, state) => AdminValuationDetailScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
    GoRoute(path: '/retail-register-success', builder: (context, state) => const RetailRegisterSuccessScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeDispatcher()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileDispatcher()),
    GoRoute(path: '/profile/edit', builder: (context, state) => const ProfileEditScreen()),
    GoRoute(
      path: '/issuing-company',
      builder: (context, state) => const IssuingCompanyScreen(),
    ),
    GoRoute(
      path: '/documentation',
      builder: (context, state) => const DocumentationScreen(),
    ),
    GoRoute(
      path: '/auditor',
      builder: (context, state) => const AuditorScreen(),
    ),
    GoRoute(
      path: '/auditor-request-detail/:requestId',
      builder: (context, state) => AuditorRequestDetailScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
    GoRoute(
      path: '/certifier',
      builder: (context, state) => const CertifierRequestsScreen(),
    ),
    GoRoute(
      path: '/certifier-request-detail/:requestId',
      builder: (context, state) => CertifierRequestDetailScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
    GoRoute(
      path: '/insurer',
      builder: (context, state) => const InsurerRequestsScreen(),
    ),
    GoRoute(
      path: '/insurer-request-detail/:requestId',
      builder: (context, state) => InsurerRequestDetailScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
    GoRoute(
      path: '/credit-issuance',
      builder: (context, state) => const CreditIssuanceScreen(),
    ),
    GoRoute(
      path: '/roadmap-editor',
      builder: (context, state) => const RoadmapEditorScreen(),
    ),
    GoRoute(
      path: '/submission-confirmation',
      builder: (context, state) => const SubmissionConfirmationScreen(),
    ),
    GoRoute(
      path: '/request-tracking/:requestId',
      builder: (context, state) => RequestTrackingScreen(
        requestId: state.pathParameters['requestId']!,
      ),
    ),
  ],
  );
});
