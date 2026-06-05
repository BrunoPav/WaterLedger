import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:water_ledger/features/shared/domain/entities/user_model.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/company_requests_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/providers/activity_providers.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/activity_tile.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_top_bar.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/section_header.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/stat_card.dart';

class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final requestsAsync = ref.watch(companyRequestsProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: DashboardTopBar(
        leading: TopBarBranded(
          avatarInitial: _avatarInitialFromUser(sessionAsync.value),
        ),
        actions: const [
          TopBarIconButton(icon: Icons.notifications_outlined),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(companyRequestsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(sessionAsync),
              const SizedBox(height: 24),
              _buildPrimaryCta(context, ref),
              const SizedBox(height: 16),
              _buildStatsRow(requestsAsync),
              const SizedBox(height: 16),
              _buildPendingActionCard(requestsAsync),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recent activity',
                actionLabel: 'View all',
                onActionTap: () {
                  // TODO: pantalla de actividad completa cuando exista el módulo de Activity Log
                },
              ),
              _buildRecentActivity(ref, sessionAsync.value?.uid ?? ''),
              const SizedBox(height: 24),
              _buildMarketplaceEmptyState(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        items: [
          DashboardNavItem(icon: Icons.home_filled, label: 'Home', onTap: () {}),
          DashboardNavItem(
            icon: Icons.pending_actions_outlined,
            label: 'Requests',
            onTap: () => _comingSoon(context, 'Requests'),
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
  //  WELCOME — nombre + badge según UserStatus
  // ------------------------------------------------------------------ //
  Widget _buildWelcomeSection(AsyncValue<UserModel?> sessionAsync) {
    return sessionAsync.when(
      loading: () => const _WelcomeSkeleton(),
      error: (e, _) => Text(
        'Error loading session: $e',
        style: const TextStyle(color: DashboardTokens.errorColor),
      ),
      data: (user) {
        if (user == null) {
          return const Text(
            'No active session',
            style: TextStyle(color: DashboardTokens.onSurfaceVariantColor),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Text(
                  'Welcome, ${user.displayName}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: DashboardTokens.primaryColor,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                ),
                _buildStatusBadge(user),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your water stewardship dashboard is up to date.',
              style: TextStyle(
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

  Widget _buildStatusBadge(UserModel user) {
    final isActive = user.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? DashboardTokens.tertiaryFixedColor
            : DashboardTokens.surfaceContainerColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 13,
            color: isActive
                ? DashboardTokens.onTertiaryFixedColor
                : DashboardTokens.onSurfaceVariantColor,
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Registered company' : 'Pending approval',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? DashboardTokens.onTertiaryFixedColor
                  : DashboardTokens.onSurfaceVariantColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  CTA PRIMARIO — Request Water Credit Issuance
  // ------------------------------------------------------------------ //
  Widget _buildPrimaryCta(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/credit-issuance'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.add_chart_outlined, color: DashboardTokens.secondaryColor, size: 26),
                const SizedBox(height: 12),
                const Text(
                  'Request Water Credit Issuance',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DashboardTokens.primaryColor,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Initiate a new certification cycle for your verified water conservation projects.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: DashboardTokens.onSurfaceVariantColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DashboardTokens.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: DashboardTokens.primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  STATS — Active Requests + Issued Credits
  // ------------------------------------------------------------------ //
  Widget _buildStatsRow(AsyncValue<List<CreditRequestEntity>> requestsAsync) {
    return requestsAsync.when(
      loading: () => Row(
        children: const [
          Expanded(
            child: StatCard(
              label: 'Active requests',
              icon: Icons.pending_outlined,
              isLoading: true,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Issued credits',
              icon: Icons.water_drop_outlined,
              isLoading: true,
            ),
          ),
        ],
      ),
      error: (e, _) => Text(
        'Error loading requests: $e',
        style: const TextStyle(color: DashboardTokens.errorColor),
      ),
      data: (requests) {
        final active = requests
            .where((r) =>
                r.status != RequestStatus.published &&
                r.status != RequestStatus.rejected)
            .toList();
        final issued = requests
            .where((r) => r.status == RequestStatus.published)
            .length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatCard(
                label: 'Active requests',
                icon: Icons.pending_outlined,
                value: active.length.toString(),
                footer: active.isNotEmpty
                    ? StatCardProgressFooter(
                        leftLabel: 'Current stage',
                        rightLabel: _statusToLabel(active.first.status),
                        progress: _statusToProgress(active.first.status),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Issued credits',
                icon: Icons.water_drop_outlined,
                iconColor: DashboardTokens.secondaryColor,
                value: issued.toString(),
                footer: const StatCardCaption(
                  icon: Icons.history,
                  text: 'Next cycle pending',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------ //
  //  PENDING ACTION CARD — sólo si hay request en estado que requiere acción
  // ------------------------------------------------------------------ //
  Widget _buildPendingActionCard(AsyncValue<List<CreditRequestEntity>> requestsAsync) {
    final requests = requestsAsync.value;
    if (requests == null) return const SizedBox.shrink();

    // Por ahora consideramos "pending action" sólo los drafts que el usuario
    // todavía no envió. Cuando exista el módulo de observaciones, también se
    // sumarán los requests con observaciones del auditor/certificador.
    final actionable = requests
        .where((r) => r.status == RequestStatus.draft)
        .toList();
    if (actionable.isEmpty) return const SizedBox.shrink();

    final draft = actionable.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashboardTokens.primaryContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_late_outlined, color: DashboardTokens.cyanColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'PENDING ACTION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DashboardTokens.cyanColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Complete your draft request',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Draft #${draft.id.substring(0, draft.id.length.clamp(0, 8))} is ready to be filled out and submitted for review.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: navegar al wizard del draft cuando exista
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardTokens.cyanColor,
                foregroundColor: DashboardTokens.onSurfaceColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Resolve Now',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  RECENT ACTIVITY — datos reales desde creditRequests
  // ------------------------------------------------------------------ //
  Widget _buildRecentActivity(WidgetRef ref, String uid) {
    final activityAsync = ref.watch(companyActivityProvider(uid));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
        ),
      ),
      child: activityAsync.when(
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
          message: 'No activity yet.',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const ActivityEmptyState(
              message: 'No activity yet — events will appear as you interact.',
            );
          }
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

  // ------------------------------------------------------------------ //
  //  MARKETPLACE EMPTY STATE
  // ------------------------------------------------------------------ //
  Widget _buildMarketplaceEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardTokens.surfaceLowestColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 36,
            color: DashboardTokens.outlineVariantColor,
          ),
          const SizedBox(height: 10),
          Text(
            'No marketplace listings',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You haven't listed any credits for sale yet. Once your credits are issued, you can list them here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ //
  //  HELPERS
  // ------------------------------------------------------------------ //
  String? _avatarInitialFromUser(UserModel? user) {
    if (user == null || user.displayName.isEmpty) return null;
    return user.displayName.trim()[0].toUpperCase();
  }

  String _statusToLabel(RequestStatus status) {
    return switch (status) {
      RequestStatus.draft => 'Draft',
      RequestStatus.pending => 'Pending',
      RequestStatus.underAudit => 'Under audit',
      RequestStatus.certified => 'Certified',
      RequestStatus.insured => 'Insured',
      RequestStatus.valued => 'Valued',
      RequestStatus.published => 'Published',
      RequestStatus.rejected => 'Rejected',
    };
  }

  double _statusToProgress(RequestStatus status) {
    return switch (status) {
      RequestStatus.draft => 0.1,
      RequestStatus.pending => 0.25,
      RequestStatus.underAudit => 0.45,
      RequestStatus.certified => 0.65,
      RequestStatus.insured => 0.8,
      RequestStatus.valued => 0.9,
      RequestStatus.published => 1.0,
      RequestStatus.rejected => 0.0,
    };
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

class _WelcomeSkeleton extends StatelessWidget {
  const _WelcomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 180,
          height: 26,
          decoration: BoxDecoration(
            color: DashboardTokens.surfaceContainerColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 240,
          height: 14,
          decoration: BoxDecoration(
            color: DashboardTokens.surfaceContainerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
