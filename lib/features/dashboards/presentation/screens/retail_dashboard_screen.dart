import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';

class RetailDashboardScreen extends ConsumerWidget {
  const RetailDashboardScreen({super.key});

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
          TopBarIconButton(icon: Icons.search_outlined),
          SizedBox(width: 4),
          TopBarIconButton(icon: Icons.settings_outlined),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcome(sessionAsync),
            const SizedBox(height: 20),
            _buildPortfolioCard(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Trending Credits', actionLabel: 'View all'),
            _buildEmptyListCard(
              icon: Icons.trending_up_outlined,
              title: 'Marketplace not available yet',
              message: 'Trending credits will appear when the marketplace module goes live.',
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Featured Projects'),
            _buildEmptyListCard(
              icon: Icons.image_outlined,
              title: 'No featured projects yet',
              message: 'Curated water projects will be highlighted here.',
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            // TODO: reemplazar con stream del módulo de Activity Log cuando exista.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: DashboardTokens.surfaceLowestColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
                ),
              ),
              child: const ActivityEmptyState(
                message: 'No activity yet — your trades will appear here.',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.home_filled, label: 'Home', onTap: () {}),
          DashboardNavItem(
            icon: Icons.storefront_outlined,
            label: 'Market',
            onTap: () => _comingSoon(context, 'Marketplace'),
          ),
          DashboardNavItem(
            icon: Icons.pie_chart_outline,
            label: 'Portfolio',
            onTap: () => _comingSoon(context, 'Portfolio'),
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
  Widget _buildWelcome(AsyncValue<UserModel?> sessionAsync) {
    return sessionAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (e, _) => Text(
        'Error loading session: $e',
        style: const TextStyle(color: DashboardTokens.errorColor),
      ),
      data: (user) {
        final firstName = (user?.displayName ?? '').split(' ').first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME BACK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DashboardTokens.onPrimaryContainerColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstName.isEmpty ? 'Hello,' : 'Hello, $firstName',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.primaryColor,
                letterSpacing: -0.6,
              ),
            ),
          ],
        );
      },
    );
  }

  // Portfolio card — empty state honesto: no hay módulo de portfolio aún
  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryContainerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PORTFOLIO VALUE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: cuando exista el módulo de Portfolio, reemplazar con valor real
          const Text(
            '—',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Portfolio module not available yet.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    color: DashboardTokens.cyanDimColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESG IMPACT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pending data',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Empty state genérico para secciones que dependen de módulos inexistentes
  Widget _buildEmptyListCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: DashboardTokens.outlineVariantColor),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
              height: 1.5,
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
