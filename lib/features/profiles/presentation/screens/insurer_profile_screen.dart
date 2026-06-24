import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_header.dart';
import 'package:water_ledger/features/profiles/presentation/widgets/profile_info_card.dart';

class InsurerProfileScreen extends ConsumerWidget {
  const InsurerProfileScreen({super.key});

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
        )
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
                  label: 'Aseguradora',
                  style: ProfileBadgeStyle.primary,
                ),
                if (user.isActive)
                  const ProfileBadge(
                    label: 'Activo',
                    style: ProfileBadgeStyle.positive,
                  )
                else
                  const ProfileBadge(
                    label: 'Pendiente de Aprobación',
                    style: ProfileBadgeStyle.neutral,
                    icon: Icons.hourglass_top,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const _Label('INFORMACIÓN DE LA CUENTA'),
            const SizedBox(height: 8),
            ProfileInfoCard(user: user),
            const SizedBox(height: 24),
            const _Label('RESUMEN DE CARTERA'),
            const SizedBox(height: 8),
            _buildCoveragesCard(),
            const SizedBox(height: 12),
            _buildCoverageTagsCard(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Actividad Reciente'),
            // TODO: reemplazar empty state cuando exista módulo Activity Log
            _buildEmptyActivity(),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 3,
        items: [
          DashboardNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () => context.go('/home'),
          ),
          DashboardNavItem(
            icon: Icons.security_outlined,
            label: 'Solicitudes',
            onTap: () => context.push('/insurer'),
          ),
          DashboardNavItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => _comingSoon(context, 'Alertas'),
          ),
          DashboardNavItem(icon: Icons.person_outline, label: 'Perfil', onTap: () {}),
        ],
      ),
    );
  }

  // Card oscura "ACTIVE COVERAGES" + Risk Category — sin módulo de Insurance aún
  Widget _buildCoveragesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COBERTURAS ACTIVAS',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                // TODO: cuando exista módulo Insurance, mostrar count real
                const Text(
                  '—',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Categoría de Riesgo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardTokens.cyanColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'N/A',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DashboardTokens.cyanDimColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Chips de coverage + count de plans — sin data persistida aún
  Widget _buildCoverageTagsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 16, color: DashboardTokens.secondaryColor),
                    const SizedBox(width: 6),
                    const Text(
                      'Cobertura',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardTokens.onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // TODO: cuando UserModel exponga insurerRoleData (tipos de cobertura),
                // reemplazar este placeholder con los chips reales
                Text(
                  'No disponible',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 16, color: DashboardTokens.secondaryColor),
                  const SizedBox(width: 6),
                  const Text(
                    'Planes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DashboardTokens.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // TODO: count real cuando exista módulo Insurance
              const Text(
                '—',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.primaryColor,
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
