import 'package:go_router/go_router.dart';
import 'package:water_ledger/credito_temporal_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/documentation_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/company_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/corporate_onboarding_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/retail_register_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/retail_register_success_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/login_screen.dart';
import 'package:water_ledger/core/presentation/screens/auth/register_screen.dart';
import 'package:water_ledger/core/presentation/screens/splash_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/credit_issuance_screen.dart';
import 'package:water_ledger/features/issuer/presentation/screen/issuing_company_screen.dart';
import 'package:water_ledger/home_temporal.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',//iba splash
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/corporate-onboarding', builder: (context, state) => const CorporateOnboardingScreen()),
    GoRoute(path: '/company-register-success', builder: (context, state) => const CompanyRegisterSuccessScreen()),
    GoRoute(path: '/retail-register', builder: (context, state) => const RetailRegisterScreen()),
    GoRoute(path: '/retail-register-success', builder: (context, state) => const RetailRegisterSuccessScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeTemporal()),
    GoRoute(path: '/prueba-credito', builder: (context, state) => const CreditoTemporal()),
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
  ],
);  