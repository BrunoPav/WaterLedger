import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_header.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_info_card.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

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
        actions: const [
          TopBarIconButton(icon: Icons.notifications_outlined),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              name: user.displayName,
              badges: [
                const ProfileBadge(
                  label: 'System Administrator',
                  style: ProfileBadgeStyle.primary,
                ),
                if (user.isActive)
                  const ProfileBadge(
                    label: 'Verified Status',
                    style: ProfileBadgeStyle.positive,
                    icon: Icons.verified_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const _Label('BASIC INFORMATION'),
            const SizedBox(height: 8),
            // El status del Admin se muestra como "Superuser" (override del UserStatus).
            ProfileInfoCard(user: user, statusLabelOverride: 'Superuser'),
            const SizedBox(height: 24),
            const _Label('PLATFORM GOVERNANCE'),
            const SizedBox(height: 8),
            Row(
              children: const [
                // TODO: cuando exista provider de governance metrics (counts agregados
                // de todas las solicitudes/usuarios de la plataforma), traer reales
                Expanded(
                  child: StatCard(
                    label: 'Active projects',
                    icon: Icons.account_tree_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    value: '—',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Pending approvals',
                    icon: Icons.pending_actions_outlined,
                    iconColor: DashboardTokens.errorColor,
                    value: '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildWorkflowMonitoringCard(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Audit Log'),
            // TODO: reemplazar empty state cuando exista módulo Activity Log (eventos de admin)
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
            icon: Icons.account_tree_outlined,
            label: 'Projects',
            onTap: () => _comingSoon(context, 'Projects'),
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
          DashboardNavItem(icon: Icons.person, label: 'Profile', onTap: () {}),
        ],
      ),
    );
  }

  // Workflow Monitoring — sin módulo de monitoring aún
  Widget _buildWorkflowMonitoringCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Workflow Monitoring',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardTokens.onSurfaceVariantColor,
                  ),
                ),
              ),
              Icon(Icons.more_horiz, size: 18, color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 6),
          // TODO: cuando exista provider de monitoring, mostrar status real ("All stages operational", etc)
          const Text(
            'No monitoring data',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DashboardTokens.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(height: 5, color: DashboardTokens.surfaceContainerColor),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metrics: —',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Uptime: —',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                ),
              ),
            ],
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
