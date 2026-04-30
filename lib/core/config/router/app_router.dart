import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_screen.dart';
import 'package:water_ledger/features/auditor/presentation/screens/documentation_screen.dart';
import 'package:water_ledger/features/credit_issuance/presentation/screens/credit_issuance_screen.dart';
import 'package:water_ledger/features/issuer/presentation/screen/issuing_company_screen.dart';
import 'package:water_ledger/home_temporal.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
  ],
);  