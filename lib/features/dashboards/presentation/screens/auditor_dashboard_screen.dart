import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/core/domain/entities/user_model.dart';
import 'package:water_ledger/core/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';

class AuditorDashboardScreen extends ConsumerWidget {
  const AuditorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: const TopBarTitled(title: 'Auditor Dashboard'),
        actions: const [
          TopBarIconButton(icon: Icons.notifications_outlined, hasDot: false),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubtitle(sessionAsync),
            const SizedBox(height: 20),
            _buildKpiGrid(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Assigned Audit Requests', actionLabel: 'View all'),
            _buildEmptyAssigned(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent Activity'),
            // TODO: poblar cuando exista módulo de Activity Log
            _buildEmptyActivity(),
            const SizedBox(height: 20),
            _buildEfficiencyCard(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () {}),
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
          DashboardNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => _comingSoon(context, 'Profile'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  Widget _buildSubtitle(AsyncValue<UserModel?> sessionAsync) {
    return sessionAsync.when(
      loading: () => const SizedBox(height: 16),
      error: (e, _) => Text(
        'Error: $e',
        style: const TextStyle(color: DashboardTokens.errorColor),
      ),
      data: (user) {
        final name = user?.displayName ?? '';
        return Text(
          name.isEmpty
              ? 'Manage assigned project audits and verification processes.'
              : 'Welcome, $name. Manage assigned project audits and verification processes.',
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

  // KPI grid 2x2 — empty states honestos (no hay módulo de audit assignments aún)
  Widget _buildKpiGrid() {
    // TODO: reemplazar con providers reales cuando exista el módulo de AuditAssignment
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Assigned audits',
                icon: Icons.water_drop_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Pending reviews',
                icon: Icons.copy_all_outlined,
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
                label: 'Upcoming deadlines',
                icon: Icons.calendar_month_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: '—',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Doc requests',
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

  Widget _buildEmptyAssigned() {
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
            Icons.assignment_outlined,
            size: 36,
            color: DashboardTokens.outlineVariantColor,
          ),
          const SizedBox(height: 10),
          const Text(
            'No audits assigned yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Once issuers submit requests and an admin assigns them, they will appear here.',
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

  // Card de eficiencia — sin data real, muestra rating "—"
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
            'Audit Efficiency',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Performance metrics will be available after your first completed audits.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance rating: —',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Verification capacity: —',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
