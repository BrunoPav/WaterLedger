import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auditor/presentation/screens/auditor_dashboard_screen.dart';
import 'package:water_ledger/features/certifier/presentation/screens/certifier_dashboard_screen.dart';
import 'package:water_ledger/features/dashboards/presentation/screens/company_dashboard_screen.dart';
import 'package:water_ledger/features/insurer/presentation/screens/insurer_dashboard_screen.dart';
import 'package:water_ledger/features/dashboards/presentation/screens/retail_dashboard_screen.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

/// Helper: muestra un loading mientras dispara `context.go(path)` en el próximo frame.
/// Se usa cuando el dispatcher tiene que redirigir (sin sesión o admin).
Widget _redirect(BuildContext context, String path) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go(path);
  });
  return const _LoadingScreen();
}

/// Punto de entrada de `/home`: mira el sessionProvider y muestra el dashboard
/// correcto según el UserModel.role del usuario logueado.
/// Si no hay sesión activa redirige a /login.
///
/// Usa StatefulWidget + addPostFrameCallback para diferir el render del
/// dashboard un frame: evita el error "Cannot hit test a render box that has
/// never been laid out" en Windows desktop cuando GoRouter hace la transición
/// a esta ruta y el mouse tracker dispara antes del primer layout.
class HomeDispatcher extends ConsumerStatefulWidget {
  const HomeDispatcher({super.key});

  @override
  ConsumerState<HomeDispatcher> createState() => _HomeDispatcherState();
}

class _HomeDispatcherState extends ConsumerState<HomeDispatcher> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const _LoadingScreen();

    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: e.toString()),
      data: (user) {
        if (user == null) {
          return _redirect(context, '/login');
        }

        return switch (user.role) {
          UserRole.retail    => const RetailDashboardScreen(),
          UserRole.company   => const CompanyDashboardScreen(),
          // Issuer comparte dashboard con Company hasta que exista IssuerDashboardScreen
          UserRole.issuer    => const CompanyDashboardScreen(),
          UserRole.auditor   => const AuditorDashboardScreen(),
          UserRole.certifier => const CertifierDashboardScreen(),
          UserRole.insurer   => const InsurerDashboardScreen(),
          UserRole.admin     => _redirect(context, '/admin-dashboard'),
        };
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: DashboardTokens.secondaryColor,
        ),
      ),
    );
  }
}

// Placeholder de Admin — ya no se usa porque admin redirige a /admin-dashboard
// (existe pantalla propia en el módulo 4.6 - core/presentation/screens/admin/).
// Se conserva comentado por si en algún momento queremos mostrar un mensaje
// intermedio antes del redirect en vez de saltar directo.
//
// class _AdminPlaceholder extends StatelessWidget {
//   const _AdminPlaceholder();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: DashboardTokens.bgColor,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.admin_panel_settings_outlined,
//                 size: 48,
//                 color: DashboardTokens.secondaryColor,
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Admin Dashboard',
//                 style: TextStyle(
//                   fontFamily: 'Manrope',
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: DashboardTokens.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Pendiente de implementar.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontFamily: 'Inter',
//                   fontSize: 13,
//                   color: DashboardTokens.onSurfaceVariantColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: DashboardTokens.errorColor,
              ),
              const SizedBox(height: 12),
              const Text(
                'Error loading session',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: DashboardTokens.onSurfaceVariantColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
