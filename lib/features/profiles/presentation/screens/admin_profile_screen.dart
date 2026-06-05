import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/enums/user_role.dart';
import 'package:water_ledger/features/shared/domain/enums/user_status.dart';
import 'package:water_ledger/features/admin/domain/repositories/admin_repository.dart';
import 'package:water_ledger/features/admin/presentation/providers/admin_provider.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/admin/presentation/screens/notifications_modal.dart';
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

    // 4.1.6.4 + módulo 4.6 — KPIs reales tomados de los providers admin.
    final pendingCount = ref.watch(pendingApprovalsCountProvider);
    final activeProjects = ref.watch(collectionCountProvider('projects'));
    final certifications = ref.watch(collectionCountProvider('certifications'));
    final valuations = ref.watch(collectionCountProvider('valuations'));
    // 4.1.6.3 — actividad reciente real (no empty state hardcodeado).
    final recentDecisions = ref.watch(recentAdminDecisionsProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          avatarInitial: user.displayName.trim().isEmpty
              ? null
              : user.displayName.trim()[0].toUpperCase(),
        ),
        actions: [
          TopBarIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => showAdminNotificationsModal(context),
          ),
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

            // 4.1.6.4 — KPIs de la plataforma. Cada card lee el provider
            // correspondiente; mientras carga muestra el spinner del StatCard.
            const _Label('PLATFORM GOVERNANCE'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    label: 'Pending approvals',
                    icon: Icons.pending_actions_outlined,
                    iconColor: DashboardTokens.errorColor,
                    asyncValue: pendingCount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpiCard(
                    label: 'Active projects',
                    icon: Icons.account_tree_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    asyncValue: activeProjects,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    label: 'Certifications',
                    icon: Icons.verified_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    asyncValue: certifications,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kpiCard(
                    label: 'Valuations',
                    icon: Icons.analytics_outlined,
                    iconColor: DashboardTokens.secondaryColor,
                    asyncValue: valuations,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4.1.6.5 — Acciones rápidas. Reemplaza el Workflow Monitoring placeholder
            // por accesos directos a las pantallas del módulo 4.6 (admin dashboard,
            // pending approvals). Más útil para el admin que un "monitoring" con data fake.
            const _Label('QUICK ACTIONS'),
            const SizedBox(height: 8),
            _buildQuickActions(context, pendingCount.maybeWhen(data: (v) => v, orElse: () => 0)),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Recent Audit Log'),
            // Feed real de approve/reject ejecutados por el admin, ordenados
            // por decisionAt descendente. Los registros previos a la introducción
            // del campo decisionAt no aparecen acá (esperado).
            _buildRecentDecisions(recentDecisions),
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

  // ------------------------------------------------------------------ //
  //  KPI card que reacciona a AsyncValue<int>
  // ------------------------------------------------------------------ //
  Widget _kpiCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required AsyncValue<int> asyncValue,
  }) {
    return asyncValue.when(
      loading: () => StatCard(label: label, icon: icon, iconColor: iconColor, isLoading: true),
      error: (_, _) => StatCard(label: label, icon: icon, iconColor: iconColor, value: '—'),
      data: (count) => StatCard(label: label, icon: icon, iconColor: iconColor, value: '$count'),
    );
  }

  // ------------------------------------------------------------------ //
  //  Quick Actions card — accesos directos al módulo 4.6.
  //  Si hay solicitudes pendientes, muestra un badge con el contador.
  // ------------------------------------------------------------------ //
  Widget _buildQuickActions(BuildContext context, int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.dashboard_customize_outlined,
            iconBg: DashboardTokens.primaryContainerColor,
            iconColor: Colors.white,
            title: 'Open Admin Dashboard',
            subtitle: 'KPIs, solicitudes y supervisión global',
            onTap: () => context.go('/admin-dashboard'),
          ),
          const Divider(height: 14, color: DashboardTokens.outlineVariantColor),
          _ActionTile(
            icon: Icons.fact_check_outlined,
            iconBg: DashboardTokens.errorColor.withValues(alpha: 0.10),
            iconColor: DashboardTokens.errorColor,
            title: 'Review Pending Approvals',
            subtitle: pendingCount == 0
                ? 'Sin solicitudes pendientes'
                : pendingCount == 1
                    ? '1 solicitud esperando revisión'
                    : '$pendingCount solicitudes esperando revisión',
            trailingBadge: pendingCount > 0 ? '$pendingCount' : null,
            // Va a la lista completa de pending approvals (no al dashboard).
            onTap: () => context.push('/admin-pending-approvals'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  Recent decisions — render del stream del repo admin
  // ------------------------------------------------------------------ //
  Widget _buildRecentDecisions(AsyncValue<List<AdminDecisionRecord>> async) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DashboardTokens.secondaryColor,
              ),
            ),
          ),
        ),
        error: (_, _) => const ActivityEmptyState(
          message: 'No se pudo cargar el log de decisiones.',
        ),
        data: (records) {
          if (records.isEmpty) {
            return const ActivityEmptyState(
              message: 'Todavía no hay decisiones registradas.',
            );
          }
          return Column(
            children: [
              for (var i = 0; i < records.length; i++)
                _decisionTile(records[i], isLast: i == records.length - 1),
            ],
          );
        },
      ),
    );
  }

  Widget _decisionTile(AdminDecisionRecord r, {required bool isLast}) {
    final isApproved = r.decision == UserStatus.active;
    final icon = isApproved ? Icons.check_circle_outline : Icons.cancel_outlined;
    final action = isApproved ? 'Aprobado' : 'Rechazado';
    final name = r.displayName.trim().isEmpty ? r.email : r.displayName;
    return ActivityTile(
      icon: icon,
      title: '$action: $name',
      subtitle: _roleLabel(r.role),
      timestamp: _timeAgo(r.decidedAt),
      isLast: isLast,
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.auditor:    return 'Auditor';
      case UserRole.certifier:  return 'Certificadora';
      case UserRole.insurer:    return 'Aseguradora';
      case UserRole.issuer:     return 'Empresa emisora';
      case UserRole.company:    return 'Empresa';
      case UserRole.retail:     return 'Retail';
      case UserRole.admin:      return 'Admin';
    }
  }

  /// Formatter relativo simple. Para >24h muestra la fecha corta.
  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inSeconds < 60) return 'hace instantes';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return DateFormat('d MMM', 'es').format(when);
  }

  void _comingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — pendiente de implementar'), duration: const Duration(seconds: 2)),
    );
  }
}

// ------------------------------------------------------------------ //
//  Label de sección (uppercase pequeña)
// ------------------------------------------------------------------ //
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

// ------------------------------------------------------------------ //
//  Tile clickeable para Quick Actions
// ------------------------------------------------------------------ //
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingBadge;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DashboardTokens.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: DashboardTokens.errorColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  trailingBadge!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
