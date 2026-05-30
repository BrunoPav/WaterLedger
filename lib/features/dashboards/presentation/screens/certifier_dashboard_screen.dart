import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/pending_approval_banner.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';

class CertifierDashboardScreen extends ConsumerWidget {
  const CertifierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          brandName: 'Water Ledger',
          avatarInitial: _avatarInitial(sessionAsync.value),
        ),
        actions: const [
          TopBarIconButton(icon: Icons.search_outlined),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sessionAsync),
            // Banner visible solo si la cuenta está pending de aprobación admin.
            // Mantiene al usuario informado de que la cuenta está en revisión.
            if (sessionAsync.value?.isPending ?? false) ...[
              const SizedBox(height: 16),
              const PendingApprovalBanner(),
            ],
            const SizedBox(height: 22),
            _buildKpiGrid(),
            const SizedBox(height: 28),
            const SectionHeader(
              title: 'Projects Awaiting Certification',
              actionLabel: 'View all',
            ),
            _buildEmptyProjects(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            // TODO: reemplazar cuando exista el módulo de Activity Log
            _buildEmptyActivity(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
          DashboardNavItem(
            icon: Icons.verified_user_outlined,
            label: 'Certifications',
            onTap: () => _comingSoon(context, 'Certifications'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            onTap: () => _comingSoon(context, 'Alerts'),
          ),
          DashboardNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  Widget _buildHeader(AsyncValue<UserModel?> sessionAsync) {
    return sessionAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (e, _) => Text(
        'Error: $e',
        style: const TextStyle(color: DashboardTokens.errorColor),
      ),
      data: (user) {
        final name = user?.displayName ?? '';
        final isPending = user?.isPending ?? false;
        // Cambiamos el subtítulo según el status: si está pending, no mostramos
        // texto de acción (porque la cuenta todavía no puede actuar) — el banner
        // amber se encarga del mensaje principal.
        final subtitle = isPending
            ? (name.isEmpty
                ? 'Your registration is currently under review.'
                : 'Welcome, $name. Your registration is currently under review.')
            : (name.isEmpty
                ? 'Review approved audit projects and manage certification decisions.'
                : 'Welcome, $name. Review approved audit projects and manage certification decisions.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certification Dashboard',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.primaryColor,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: DashboardTokens.onSurfaceVariantColor,
                height: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }

  // KPI grid 2x2 — empty states honestos
  Widget _buildKpiGrid() {
    // TODO: reemplazar con providers reales cuando exista módulo de Certifications
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Pending',
                icon: Icons.pending_actions_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Approved',
                icon: Icons.verified_rounded,
                iconColor: DashboardTokens.onTertiaryContainerColor,
                value: '—',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Rejected',
                icon: Icons.cancel_outlined,
                iconColor: DashboardTokens.errorColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Today',
                icon: Icons.analytics_outlined,
                iconColor: DashboardTokens.primaryColor,
                value: '—',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyProjects() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 36,
            color: DashboardTokens.outlineVariantColor,
          ),
          const SizedBox(height: 10),
          const Text(
            'No projects awaiting certification',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Approved audits will appear here once they reach the certification stage.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: const ActivityEmptyState(),
    );
  }

  String? _avatarInitial(UserModel? user) {
    if (user == null || user.displayName.isEmpty) return null;
    return user.displayName.trim()[0].toUpperCase();
  }

  void _comingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName — pendiente de implementar'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
