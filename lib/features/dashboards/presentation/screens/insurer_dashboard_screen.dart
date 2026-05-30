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

class InsurerDashboardScreen extends ConsumerWidget {
  const InsurerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          avatarInitial: _avatarInitial(sessionAsync.value),
        ),
        actions: const [
          TopBarIconButton(icon: Icons.notifications_outlined),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sessionAsync),
            // Banner visible solo si la cuenta está pending de aprobación admin.
            if (sessionAsync.value?.isPending ?? false) ...[
              const SizedBox(height: 16),
              const PendingApprovalBanner(),
            ],
            const SizedBox(height: 22),
            _buildKpiGrid(),
            const SizedBox(height: 28),
            const SectionHeader(
              title: 'Projects Eligible for Coverage',
              actionLabel: 'View all',
            ),
            _buildEmptyProjects(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            // TODO: reemplazar cuando exista el módulo de Activity Log
            _buildEmptyActivity(),
            const SizedBox(height: 20),
            _buildSecurityRatingCard(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.home_filled, label: 'Home', onTap: () {}),
          DashboardNavItem(
            icon: Icons.pending_actions_outlined,
            label: 'Requests',
            onTap: () => _comingSoon(context, 'Requests'),
          ),
          DashboardNavItem(
            icon: Icons.water_drop_outlined,
            label: 'Credits',
            onTap: () => _comingSoon(context, 'Credits'),
          ),
          DashboardNavItem(
            icon: Icons.storefront_outlined,
            label: 'Market',
            onTap: () => _comingSoon(context, 'Marketplace'),
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
        // Si está pending no mostramos el texto de acción ("Manage insurance plans...")
        // porque la cuenta no puede actuar aún — el banner ámbar amplifica el mensaje.
        final subtitle = isPending
            ? (name.isEmpty
                ? 'Your registration is currently under review.'
                : 'Welcome, $name. Your registration is currently under review.')
            : (name.isEmpty
                ? 'Manage insurance plans and review eligible sustainability projects.'
                : 'Welcome, $name. Manage insurance plans and review eligible sustainability projects.');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Dashboard',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.primaryColor,
                letterSpacing: -0.5,
                height: 1.2,
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
    // TODO: reemplazar con providers reales cuando exista módulo de Insurance Plans
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Eligible projects',
                icon: Icons.eco_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Active plans',
                icon: Icons.verified_user_outlined,
                iconColor: DashboardTokens.secondaryColor,
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
                label: 'Selected coverages',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Recent activity',
                icon: Icons.history,
                iconColor: DashboardTokens.secondaryColor,
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
            Icons.shield_outlined,
            size: 36,
            color: DashboardTokens.outlineVariantColor,
          ),
          const SizedBox(height: 10),
          const Text(
            'No projects eligible for coverage yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Certified projects will appear here for insurance plan creation.',
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

  Widget _buildSecurityRatingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryContainerColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: DashboardTokens.cyanDimColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Security Rating',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Provider security score will be calculated after underwriting metrics are available.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 5,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
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
