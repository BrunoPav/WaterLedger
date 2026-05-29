import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/Stitch_Templates/Steps/step_3_project_info/project_info_step_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/documentation_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/auditor_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/certifier_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/insurance_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/company_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/corporate_onboarding_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/retail_register_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/retail_register_success_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/login_screen.dart';
import 'package:water_ledger/features/auth/presentation/screens/register_screen.dart';
import 'package:water_ledger/core/presentation/screens/splash_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/credit_issuance_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/roadmap_editor_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/submission_confirmation_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/request_tracking_screen.dart';
import 'package:water_ledger/features/issuer/presentation/screen/issuing_company_screen.dart';
import 'package:water_ledger/home_temporal.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/home', //iba splash
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/corporate-onboarding', builder: (context, state) => const CorporateOnboardingScreen()),
    GoRoute(path: '/company-register-success', builder: (context, state) => const CompanyRegisterSuccessScreen()),
    GoRoute(path: '/retail-register', builder: (context, state) => const RetailRegisterScreen()),
    GoRoute(path: '/auditor-register', builder: (context, state) => const AuditorRegisterScreen()),
    GoRoute(path: '/register-success', builder: (context, state) => const RegisterSuccessScreen()),
    GoRoute(path: '/certifier-register', builder: (context, state) => const CertifierRegisterScreen()),
    GoRoute(path: '/insurance-register', builder: (context, state) => const InsuranceRegisterScreen()),
    GoRoute(path: '/insurance-register-success', builder: (context, state) => const RegisterSuccessScreen()),
    GoRoute(path: '/retail-register-success', builder: (context, state) => const RetailRegisterSuccessScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeTemporal()),
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
