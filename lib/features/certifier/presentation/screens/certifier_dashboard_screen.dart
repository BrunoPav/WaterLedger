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
    final uid = sessionAsync.value?.uid ?? '';
    final requestsAsync = ref.watch(certifiedRequestsProvider);
    final statsAsync = ref.watch(certifierStatsProvider(uid));

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          brandName: 'Water Ledger',
          avatarInitial: _avatarInitial(sessionAsync.value),
        )
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(certifiedRequestsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(sessionAsync),
              const SizedBox(height: 22),
              _buildKpiGrid(requestsAsync, statsAsync),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Solicitudes a Certificar',
                actionLabel: 'Ver todas',
                onActionTap: () => context.push('/certifier'),
              ),
              _buildAwaitingCertification(context, requestsAsync),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Actividad Reciente'),
              _buildRecentActivity(ref, uid),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
          DashboardNavItem(
            icon: Icons.verified_user_outlined,
            label: 'Certificaciones',
            onTap: () => context.push('/certifier'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => _comingSoon(context, 'Alertas'),
          ),
          DashboardNavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
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
              'Panel de Certificación',
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
                  ? 'Revisá los proyectos aprobados por auditoría y gestioná las decisiones de certificación.'
                  : 'Bienvenido, $name. Revisá los proyectos aprobados por auditoría y gestioná las decisiones de certificación.',
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

  Widget _buildKpiGrid(
    AsyncValue<List<CreditRequestEntity>> requestsAsync,
    AsyncValue<CertifierStats> statsAsync,
  ) {
    final pendingLoading = requestsAsync.isLoading;
    final pending = requestsAsync.asData?.value.length;
    final statsLoading = statsAsync.isLoading;
    final stats = statsAsync.asData?.value;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Pendientes',
                icon: Icons.pending_actions_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: pendingLoading ? null : '${pending ?? 0}',
                isLoading: pendingLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Aprobados',
                icon: Icons.verified_rounded,
                iconColor: DashboardTokens.onTertiaryContainerColor,
                value: statsLoading ? null : '${stats?.approved ?? 0}',
                isLoading: statsLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Rechazados',
                icon: Icons.cancel_outlined,
                iconColor: DashboardTokens.errorColor,
                value: statsLoading ? null : '${stats?.rejected ?? 0}',
                isLoading: statsLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Hoy',
                icon: Icons.analytics_outlined,
                iconColor: DashboardTokens.primaryColor,
                value: statsLoading ? null : '${stats?.today ?? 0}',
                isLoading: statsLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAwaitingCertification(
    BuildContext context,
    AsyncValue<List<CreditRequestEntity>> requestsAsync,
  ) {
    return requestsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: DashboardTokens.secondaryColor),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFF93000A), size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No se pudieron cargar las solicitudes.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF93000A)),
              ),
            ),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) return _buildEmptyProjects();
        final preview = requests.take(3).toList();
        return Column(
          children: [
            ...preview.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CertificationTile(
                request: r,
                onTap: () => context.push('/certifier-request-detail/${r.id}'),
              ),
            )),
            if (requests.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.push('/certifier'),
                  child: const Text(
                    'Ver todas las solicitudes →',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DashboardTokens.secondaryColor,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
            'Sin solicitudes por certificar',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Las auditorías aprobadas aparecerán acá al llegar a la etapa de certificación.',
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

// ── Compact tile for dashboard preview ───────────────────────────────────────
class _CertificationTile extends StatelessWidget {
  const _CertificationTile({required this.request, required this.onTap});

  final CreditRequestEntity request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF2E7D32);
    final projectName = request.project?.name;
    final date = request.submittedAt ?? request.createdAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DashboardTokens.surfaceLowestColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName ?? 'Sin nombre de proyecto',
                    style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700,
                      color: projectName != null ? DashboardTokens.onSurfaceColor : DashboardTokens.onSurfaceVariantColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: color.withValues(alpha: 0.25)),
                        ),
                        child: const Text('Aprobado por Auditoría', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM yyyy', 'es').format(date),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: DashboardTokens.onSurfaceVariantColor, size: 18),
          ],
        ),
      ),
    );
  }
}
