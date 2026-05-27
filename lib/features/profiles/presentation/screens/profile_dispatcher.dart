import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/enums/user_role.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/profiles/presentation/screens/admin_profile_screen.dart';
import 'package:water_ledger/features/profiles/presentation/screens/auditor_profile_screen.dart';
import 'package:water_ledger/features/profiles/presentation/screens/certifier_profile_screen.dart';
import 'package:water_ledger/features/profiles/presentation/screens/company_profile_screen.dart';
import 'package:water_ledger/features/profiles/presentation/screens/insurer_profile_screen.dart';
import 'package:water_ledger/features/profiles/presentation/screens/retail_profile_screen.dart';

/// Punto de entrada de `/profile`: igual que el HomeDispatcher pero para perfiles.
/// Muestra la pantalla de perfil correspondiente al rol del usuario logueado.
class ProfileDispatcher extends ConsumerWidget {
  const ProfileDispatcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => _ErrorScaffold(message: e.toString()),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/login');
          });
          return const _LoadingScaffold();
        }
        return switch (user.role) {
          UserRole.retail => const RetailProfileScreen(),
          UserRole.company => const CompanyProfileScreen(),
          UserRole.auditor => const AuditorProfileScreen(),
          UserRole.certifier => const CertifierProfileScreen(),
          UserRole.insurer => const InsurerProfileScreen(),
          UserRole.admin => const AdminProfileScreen(),
        };
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

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

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

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
                'Error loading profile',
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
