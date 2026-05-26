import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/documentation_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/auditor_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/auditor_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/certifier_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/certifier_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/insurance_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/insurance_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/admin_seed_screen.dart';
import 'package:water_ledger/core/presentation/screens/admin/pending_request_detail_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/company_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/corporate_onboarding_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/retail_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/retail_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/login_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/register_screen.dart';
import 'package:water_ledger/core/presentation/screens/splash_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/credit_issuance_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/roadmap_editor_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/submission_confirmation_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/request_tracking_screen.dart';
import 'package:water_ledger/features/dashboards/presentation/screens/home_dispatcher.dart';
import 'package:water_ledger/features/issuer/presentation/screen/issuing_company_screen.dart';
import 'package:water_ledger/home_temporal.dart';

import 'package:water_ledger/core/Stitch_Templates/Steps/step_3_project_info/project_info_step_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', //iba splash
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/corporate-onboarding', builder: (context, state) => const CorporateOnboardingScreen()),
    GoRoute(path: '/company-register-success', builder: (context, state) => const CompanyRegisterSuccessScreen()),
    GoRoute(path: '/retail-register', builder: (context, state) => const RetailRegisterScreen()),
    GoRoute(path: '/auditor-register', builder: (context, state) => const AuditorRegisterScreen()),
    GoRoute(path: '/auditor-register-success', builder: (context, state) => const AuditorRegisterSuccessScreen()),
    GoRoute(path: '/certifier-register', builder: (context, state) => const CertifierRegisterScreen()),
    GoRoute(path: '/certifier-register-success', builder: (context, state) => const CertifierRegisterSuccessScreen()),
    GoRoute(path: '/insurance-register', builder: (context, state) => const InsuranceRegisterScreen()),
    GoRoute(path: '/insurance-register-success', builder: (context, state) => const InsuranceRegisterSuccessScreen()),
    // ---- Admin (4.6 Gestión del Administrador) ---- //
    GoRoute(path: '/admin-seed', builder: (context, state) => const AdminSeedScreen()),
    GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(
      path: '/admin-pending-detail/:uid',
      builder: (context, state) => PendingRequestDetailScreen(
        uid: state.pathParameters['uid']!,
      ),
    ),
    GoRoute(path: '/retail-register-success', builder: (context, state) => const RetailRegisterSuccessScreen()),
    // Versión anterior — apuntaba a HomeTemporal (pantalla de testing con botones):
    // GoRoute(path: '/home', builder: (context, state) => const HomeTemporal()),
    // Ahora /home despacha al dashboard correspondiente al rol del usuario logueado
    // (módulo 4.1.6 + 4.1.4.6 — Dashboard inicial + Navegación dinámica por rol).
    GoRoute(path: '/home', builder: (context, state) => const HomeDispatcher()),
    // HomeTemporal queda accesible bajo /home-temporal para testing manual:
    GoRoute(path: '/home-temporal', builder: (context, state) => const HomeTemporal()),
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
      path: '/request-tracking',
      builder: (context, state) => const RequestTrackingScreen(),
    ),
    GoRoute(
      path: '/project-info-test',
      builder: (context, state) => const ProjectInfoStepScreen(),
    ),
  ],
);
