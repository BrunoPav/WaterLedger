import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/company_requests_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_header.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_info_card.dart';

class CompanyProfileScreen extends ConsumerWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final requestsAsync = ref.watch(companyRequestsProvider);

    final user = sessionAsync.value;
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
                  label: 'Compania registrada',
                  style: ProfileBadgeStyle.info,
                  icon: Icons.verified_outlined,
                ),
                if (user.isPending)
                  ProfileBadge(
                    label: 'Pendiente de Aprobación',
                    style: ProfileBadgeStyle.neutral,
                    icon: Icons.hourglass_top,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const _SmallSectionLabel('INFORMACION BASICA'),
            const SizedBox(height: 8),
            ProfileInfoCard(user: user),
            const SizedBox(height: 24),
            const _SmallSectionLabel('ESTADISTICAS DE IMPACTO'),
            const SizedBox(height: 8),
            _buildStatsRow(requestsAsync),
            const SizedBox(height: 12),
            _buildIssuedCreditsCard(requestsAsync),
            const SizedBox(height: 12),
            _buildInsuranceStatusCard(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Actividad Reciente'),
            // TODO: reemplazar empty state cuando exista módulo de Activity Log
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
            icon: Icons.pending_actions_outlined,
            label: 'Requests',
            onTap: () => context.push('/company-requests'),
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

  // Stats row: Active Projects + Certified Projects (calculadas de requests reales)
  Widget _buildStatsRow(AsyncValue<List<CreditRequestEntity>> requestsAsync) {
    return requestsAsync.when(
      loading: () => Row(
        children: const [
          Expanded(child: StatCard(label: 'Active projects', icon: Icons.water_drop_outlined, isLoading: true)),
          SizedBox(width: 12),
          Expanded(child: StatCard(label: 'Certified projects', icon: Icons.verified_user_outlined, isLoading: true)),
        ],
      ),
      error: (e, _) => Text('Error: $e', style: const TextStyle(color: DashboardTokens.errorColor)),
      data: (requests) {
        final active = requests
            .where((r) =>
                r.status != RequestStatus.published &&
                r.status != RequestStatus.rejected)
            .length;
        final certified = requests
            .where((r) =>
                r.status == RequestStatus.certified ||
                r.status == RequestStatus.insured ||
                r.status == RequestStatus.valued ||
                r.status == RequestStatus.published)
            .length;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Proyectos activos',
                icon: Icons.water_drop_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: active.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Proyectos certificados',
                icon: Icons.verified_user_outlined,
                iconColor: DashboardTokens.onTertiaryContainerColor,
                value: certified.toString(),
              ),
            ),
          ],
        );
      },
    );
  }

  // Total Issued Credits con barra de progreso
  Widget _buildIssuedCreditsCard(AsyncValue<List<CreditRequestEntity>> requestsAsync) {
    final requests = requestsAsync.value ?? [];
    // Total emitido = suma del creditAmount de requests en estado published.
    final totalIssued = requests
        .where((r) => r.status == RequestStatus.published)
        .fold<double>(0, (sum, r) => sum + r.creditAmount);
    final totalRequested = requests.fold<double>(0, (sum, r) => sum + r.creditAmount);
    final ratio = totalRequested == 0 ? 0.0 : totalIssued / totalRequested;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: DashboardTokens.secondaryColor, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Total Issued Credits',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardTokens.onSurfaceColor,
                  ),
                ),
              ),
              Text(
                totalIssued == 0 ? '—' : totalIssued.toStringAsFixed(0),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Container(height: 5, color: DashboardTokens.surfaceContainerColor),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        DashboardTokens.primaryContainerColor,
                        DashboardTokens.cyanDimColor,
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Insurance Status — sin módulo de seguros aún, empty state honesto
  Widget _buildInsuranceStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: DashboardTokens.onSurfaceVariantColor, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Insurance Status',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DashboardTokens.onSurfaceColor,
              ),
            ),
          ),
          // TODO: cuando exista módulo de Insurance, mostrar estado real
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: DashboardTokens.surfaceContainerColor,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Not available',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DashboardTokens.onSurfaceVariantColor,
              ),
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

  void _comingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — pendiente de implementar'), duration: const Duration(seconds: 2)),
    );
  }
}

class _SmallSectionLabel extends StatelessWidget {
  final String text;
  const _SmallSectionLabel(this.text);

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
