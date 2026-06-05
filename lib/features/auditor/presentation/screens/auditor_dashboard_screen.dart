import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/dashboards/presentation/providers/activity_providers.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/auditor/presentation/providers/auditor_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';

const _statusMeta = <String, (String, Color)>{
  'draft':      ('Borrador',      Color(0xFF9E9E9E)),
  'pending':    ('Pendiente',     Color(0xFFFF8F00)),
  'underAudit': ('En auditoría',  Color(0xFF1565C0)),
  'certified':  ('Certificado',   Color(0xFF2E7D32)),
  'insured':    ('Asegurado',     Color(0xFF00695C)),
  'valued':     ('Valorado',      Color(0xFF6A1B9A)),
  'published':  ('Publicado',     Color(0xFF1B5E20)),
  'rejected':   ('Rechazado',     Color(0xFFC62828)),
};

class AuditorDashboardScreen extends ConsumerWidget {
  const AuditorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final assignmentsAsync = ref.watch(auditorAssignmentsProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: const TopBarTitled(title: 'Auditor Dashboard'),
        actions: const [
          TopBarIconButton(icon: Icons.notifications_outlined, hasDot: false),
        ],
      ),
      body: RefreshIndicator(
        color: DashboardTokens.secondaryColor,
        onRefresh: () => ref.refresh(auditorAssignmentsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubtitle(sessionAsync),
              const SizedBox(height: 20),
              _buildKpiGrid(assignmentsAsync),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Solicitudes Asignadas',
                actionLabel: 'Ver todas',
                onActionTap: () => context.push('/auditor'),
              ),
              _buildAssignedSection(context, assignmentsAsync),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Actividad Reciente'),
              _buildRecentActivity(ref, sessionAsync.value?.uid ?? ''),
              const SizedBox(height: 20),
              _buildEfficiencyCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
          DashboardNavItem(
            icon: Icons.pending_actions_outlined,
            label: 'Audits',
            onTap: () => context.push('/auditor'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alerts — pendiente de implementar'), duration: Duration(seconds: 2)),
            ),
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

  // ── Subtitle ────────────────────────────────────────────────────────────────
  Widget _buildSubtitle(AsyncValue<UserModel?> sessionAsync) {
    return sessionAsync.when(
      loading: () => const SizedBox(height: 16),
      error: (e, _) => const SizedBox.shrink(),
      data: (user) {
        final name = user?.displayName ?? '';
        return Text(
          name.isEmpty
              ? 'Gestioná las solicitudes de auditoría asignadas.'
              : 'Bienvenido, $name. Gestioná tus auditorías asignadas.',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: DashboardTokens.onSurfaceVariantColor,
            height: 1.5,
          ),
        );
      },
    );
  }

  // ── KPI grid ────────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(AsyncValue<List<CreditRequestEntity>> assignmentsAsync) {
    final isLoading = assignmentsAsync.isLoading;
    final assignments = assignmentsAsync.asData?.value ?? [];
    final pendingCount = assignments
        .where((r) => r.status == RequestStatus.underAudit)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Asignadas',
                icon: Icons.water_drop_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: isLoading ? null : '${assignments.length}',
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Pendientes',
                icon: Icons.copy_all_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: isLoading ? null : '$pendingCount',
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Próx. vencimientos',
                icon: Icons.calendar_month_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Docs solicitados',
                icon: Icons.description_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Assigned requests section ────────────────────────────────────────────────
  Widget _buildAssignedSection(
    BuildContext context,
    AsyncValue<List<CreditRequestEntity>> assignmentsAsync,
  ) {
    return assignmentsAsync.when(
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
                'No se pudieron cargar las asignaciones.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF93000A)),
              ),
            ),
          ],
        ),
      ),
      data: (assignments) {
        if (assignments.isEmpty) return _buildEmptyAssigned();
        final preview = assignments.take(3).toList();
        return Column(
          children: [
            ...preview.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AssignmentTile(
                request: r,
                onTap: () => context.push('/auditor-request-detail/${r.id}'),
              ),
            )),
            if (assignments.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.push('/auditor'),
                  child: const Text(
                    'Ver todas las asignaciones →',
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

  Widget _buildEmptyAssigned() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 36, color: DashboardTokens.outlineVariantColor),
          const SizedBox(height: 10),
          const Text(
            'Sin solicitudes asignadas',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, color: DashboardTokens.onSurfaceColor),
          ),
          const SizedBox(height: 6),
          Text(
            'El administrador te asignará solicitudes de crédito para auditar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref, String uid) {
    final activityAsync = ref.watch(auditorActivityProvider(uid));
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

  Widget _buildEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eficiencia de Auditoría',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Las métricas de rendimiento estarán disponibles al completar tus primeras auditorías.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.75), height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rendimiento: —', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.3)),
              Text('Capacidad: —', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Compact assignment tile for dashboard preview ────────────────────────────
class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.request, required this.onTap});

  final CreditRequestEntity request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusKey = request.status.name;
    final (label, color) = _statusMeta[statusKey] ?? ('Desconocido', const Color(0xFF9E9E9E));
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
              child: Icon(Icons.assignment_outlined, color: color, size: 20),
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
                        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
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
