import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/certifier/presentation/providers/certifier_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/dashboards/presentation/providers/activity_providers.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
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
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sessionAsync),
            const SizedBox(height: 22),
            _buildKpiGrid(ref),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Projects Awaiting Certification',
              actionLabel: 'View all',
              onActionTap: () => context.push('/certifier'),
            ),
            _buildProjects(context, ref),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            _buildRecentActivity(ref, sessionAsync.value?.uid ?? ''),
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
            onTap: () => context.push('/certifier'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => _comingSoon(context, 'Alertas'),
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
              name.isEmpty
                  ? 'Review approved audit projects and manage certification decisions.'
                  : 'Welcome, $name. Review approved audit projects and manage certification decisions.',
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

  Widget _buildKpiGrid(WidgetRef ref) {
    final statsAsync = ref.watch(certifierStatsProvider);
    final stats = statsAsync.value;
    final loading = statsAsync.isLoading;
    String v(int? n) => n?.toString() ?? '—';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Pending',
                icon: Icons.pending_actions_outlined,
                iconColor: DashboardTokens.secondaryColor,
                isLoading: loading,
                value: v(stats?.pending),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Approved',
                icon: Icons.verified_rounded,
                iconColor: DashboardTokens.onTertiaryContainerColor,
                isLoading: loading,
                value: v(stats?.approved),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Rejected',
                icon: Icons.cancel_outlined,
                iconColor: DashboardTokens.errorColor,
                isLoading: loading,
                value: v(stats?.rejected),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Today',
                icon: Icons.analytics_outlined,
                iconColor: DashboardTokens.primaryColor,
                isLoading: loading,
                value: v(stats?.today),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjects(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(certifiedRequestsProvider);
    return requestsAsync.when(
      loading: () => _projectsCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: DashboardTokens.secondaryColor),
            ),
          ),
        ),
      ),
      error: (_, _) => _buildEmptyProjects(),
      data: (requests) {
        if (requests.isEmpty) return _buildEmptyProjects();
        final shown = requests.take(3).toList();
        return _projectsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < shown.length; i++)
                _ProjectTile(
                  request: shown[i],
                  isLast: i == shown.length - 1,
                  onTap: () => context.push('/certifier-request-detail/${shown[i].id}'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _projectsCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }

  Widget _buildEmptyProjects() {
    return _projectsCard(
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

  Widget _buildRecentActivity(WidgetRef ref, String uid) {
    final activityAsync = ref.watch(certifierActivityProvider(uid));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: activityAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: DashboardTokens.secondaryColor))),
        ),
        error: (_, _) => const ActivityEmptyState(message: 'No se pudo cargar la actividad.'),
        data: (items) {
          if (items.isEmpty) return const ActivityEmptyState();
          return Column(
            children: [
              for (var i = 0; i < items.length; i++)
                ActivityTile(
                  icon: items[i].icon,
                  title: items[i].title,
                  subtitle: items[i].subtitle,
                  timestamp: _timeAgo(items[i].timestamp),
                  isLast: i == items.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inSeconds < 60) return 'hace instantes';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return DateFormat('d MMM', 'es').format(when);
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

// ── Project tile (compacto, para el dashboard) ────────────────────────────────
class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.request,
    required this.isLast,
    required this.onTap,
  });

  final CreditRequestEntity request;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final projectName = request.project?.name;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.25),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DashboardTokens.secondaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined,
                  color: DashboardTokens.secondaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName ?? 'Sin nombre de proyecto',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: projectName != null
                          ? DashboardTokens.onSurfaceColor
                          : DashboardTokens.onSurfaceVariantColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    request.id,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: DashboardTokens.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: DashboardTokens.onSurfaceVariantColor, size: 20),
          ],
        ),
      ),
    );
  }
}
