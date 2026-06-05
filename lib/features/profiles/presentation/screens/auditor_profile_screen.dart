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

class AuditorProfileScreen extends ConsumerWidget {
  const AuditorProfileScreen({super.key});

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
                  label: 'Certified Auditor',
                  style: ProfileBadgeStyle.primary,
                ),
                if (user.isActive)
                  const ProfileBadge(
                    label: 'Verified',
                    style: ProfileBadgeStyle.positive,
                    icon: Icons.verified_outlined,
                  )
                else
                  const ProfileBadge(
                    label: 'Pending Approval',
                    style: ProfileBadgeStyle.neutral,
                    icon: Icons.hourglass_top,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const _Label('ACCOUNT INFORMATION'),
            const SizedBox(height: 8),
            ProfileInfoCard(user: user),
            const SizedBox(height: 24),
            const _Label('EXPERTISE & METRICS'),
            const SizedBox(height: 8),
            Row(
              children: const [
                // TODO: cuando exista módulo de AuditAssignment, traer counts reales
                Expanded(
                  child: StatCard(
                    label: 'Completed audits',
                    icon: Icons.fact_check_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    value: '—',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Assigned projects',
                    icon: Icons.assignment_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    value: '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildExpertiseCard(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            // TODO: reemplazar empty state cuando exista módulo Activity Log
            _buildEmptyActivity(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 3,
        items: [
          DashboardNavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => context.go('/home'),
          ),
          DashboardNavItem(
            icon: Icons.pending_actions_outlined,
            label: 'Audits',
            onTap: () => _comingSoon(context, 'Audits'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            onTap: () => _comingSoon(context, 'Alerts'),
          ),
          DashboardNavItem(icon: Icons.person, label: 'Profile', onTap: () {}),
        ],
      ),
    );
  }

  // Card de especializaciones y certificaciones — sin data persistida aún
  // (los chips se eligieron en el wizard de registro pero no se exponen al UserModel).
  Widget _buildExpertiseCard() {
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
          const Text(
            'Audit Specializations',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: cuando UserModel exponga las specializations + certifications
          // del auditorRoleData en Firestore, reemplazar este empty state por chips reales
          Text(
            'Specializations not loaded',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
            ),
          ),
          const Divider(height: 22, color: DashboardTokens.outlineVariantColor),
          const Text(
            'Certifications',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Certifications not loaded',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
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
