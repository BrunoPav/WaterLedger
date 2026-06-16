import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_header.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_info_card.dart';

class RetailProfileScreen extends ConsumerWidget {
  const RetailProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          avatarInitial: user.displayName.trim().isEmpty
              ? null
              : user.displayName.trim()[0].toUpperCase(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              name: user.displayName,
              badges: [
                ProfileBadge(
                  label: 'Verified Investor',
                  style: ProfileBadgeStyle.info,
                  icon: Icons.verified_outlined,
                ),
                if (user.isActive)
                  const ProfileBadge(
                    label: 'Approved',
                    style: ProfileBadgeStyle.positive,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const _Label('PORTFOLIO SUMMARY'),
            const SizedBox(height: 8),
            _buildPortfolioCard(),
            const SizedBox(height: 12),
            Row(
              children: const [
                // TODO: reemplazar con providers reales cuando exista módulo Marketplace + Portfolio
                Expanded(
                  child: StatCard(
                    label: 'Credits Owned',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    value: '—',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'ESG Projects',
                    icon: Icons.eco_outlined,
                    iconColor: DashboardTokens.onTertiaryContainerColor,
                    value: '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _Label('ACCOUNT INFORMATION'),
            const SizedBox(height: 8),
            ProfileInfoCard(user: user),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity', actionLabel: 'View All'),
            // TODO: reemplazar empty state cuando exista módulo Activity Log
            _buildEmptyActivity(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 4,
        items: [
          DashboardNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () => context.go('/home'),
          ),
          DashboardNavItem(
            icon: Icons.storefront_outlined,
            label: 'Market',
            onTap: () => _comingSoon(context, 'Marketplace'),
          ),
          DashboardNavItem(
            icon: Icons.pie_chart_outline,
            label: 'Cartera',
            onTap: () => _comingSoon(context, 'Cartera'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => _comingSoon(context, 'Alertas'),
          ),
          DashboardNavItem(icon: Icons.person, label: 'Profile', onTap: () {}),
        ],
      ),
    );
  }

  // Portfolio Value card oscura — sin módulo de Portfolio aún
  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PORTFOLIO VALUE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          // TODO: cuando exista módulo Portfolio, mostrar valor real
          const Text(
            '—',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(height: 5, color: Colors.white.withValues(alpha: 0.15)),
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
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: const ActivityEmptyState(),
    );
  }

  void _comingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — pendiente de implementar'), duration: const Duration(seconds: 2)),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: DashboardTokens.onSurfaceVariantColor,
        letterSpacing: 1.0,
      ),
    );
  }
}
