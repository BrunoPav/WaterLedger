import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/valuation/presentation/providers/valuation_repository_provider.dart';

const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);
const _errorColor            = Color(0xFFC62828);
const _valuedColor           = Color(0xFF6A1B9A);
const _insuredColor          = Color(0xFF00695C);

class AdminValuationsListScreen extends ConsumerStatefulWidget {
  const AdminValuationsListScreen({super.key});

  @override
  ConsumerState<AdminValuationsListScreen> createState() =>
      _AdminValuationsListScreenState();
}

class _AdminValuationsListScreenState
    extends ConsumerState<AdminValuationsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _onSurfaceColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Valorización y Publicación',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _onSurfaceColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: _secondaryColor,
          unselectedLabelColor: _onSurfaceVariantColor,
          indicatorColor: _secondaryColor,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Por Valorizar'),
            Tab(text: 'Por Publicar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _InsuredTab(key: const ValueKey('insured')),
          _ValuedTab(key: const ValueKey('valued')),
        ],
      ),
    );
  }
}

// ── Tab: solicitudes insured → pendientes de valorizar ─────────────────────────

class _InsuredTab extends ConsumerWidget {
  const _InsuredTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insuredRequestsForAdminProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _secondaryColor)),
      error: (e, _) => _errorBox('No se pudieron cargar las solicitudes: $e'),
      data: (requests) {
        if (requests.isEmpty) {
          return _emptyState(
            icon: Icons.analytics_outlined,
            title: 'Sin solicitudes para valorizar',
            subtitle: 'Cuando una solicitud complete el proceso de seguros, aparecerá acá para su valorización.',
          );
        }
        return RefreshIndicator(
          color: _secondaryColor,
          onRefresh: () async => ref.invalidate(insuredRequestsForAdminProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _RequestCard(
              request: requests[i],
              actionLabel: 'Valorizar',
              actionIcon: Icons.price_check_outlined,
              badgeColor: _insuredColor,
              badgeLabel: 'Asegurado',
              route: '/admin-valuation-detail/${requests[i].id}',
            ),
          ),
        );
      },
    );
  }
}

// ── Tab: solicitudes valued → pendientes de publicar ──────────────────────────

class _ValuedTab extends ConsumerWidget {
  const _ValuedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(valuedRequestsForAdminProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _secondaryColor)),
      error: (e, _) => _errorBox('No se pudieron cargar las solicitudes: $e'),
      data: (requests) {
        if (requests.isEmpty) {
          return _emptyState(
            icon: Icons.publish_outlined,
            title: 'Sin solicitudes para publicar',
            subtitle: 'Las solicitudes ya valorizadas aparecerán acá listas para publicar en el marketplace.',
          );
        }
        return RefreshIndicator(
          color: _secondaryColor,
          onRefresh: () async => ref.invalidate(valuedRequestsForAdminProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _RequestCard(
              request: requests[i],
              actionLabel: 'Ver / Publicar',
              actionIcon: Icons.publish_outlined,
              badgeColor: _valuedColor,
              badgeLabel: 'Valorizado',
              route: '/admin-valuation-detail/${requests[i].id}',
            ),
          ),
        );
      },
    );
  }
}

// ── Card compartida ───────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.actionLabel,
    required this.actionIcon,
    required this.badgeColor,
    required this.badgeLabel,
    required this.route,
  });

  final CreditRequestEntity request;
  final String actionLabel;
  final IconData actionIcon;
  final Color badgeColor;
  final String badgeLabel;
  final String route;

  @override
  Widget build(BuildContext context) {
    final name = request.project?.name ?? 'Sin nombre';
    final company = request.issuerCompanyId;
    final credits = request.creditAmount.toStringAsFixed(0);
    final date = request.submittedAt ?? request.createdAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.id,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _onSurfaceVariantColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.water_drop_outlined, '$credits m³ de créditos'),
          const SizedBox(height: 4),
          _infoRow(Icons.business_outlined, company),
          const SizedBox(height: 4),
          _infoRow(
            Icons.calendar_today_outlined,
            'Enviada ${DateFormat('d MMM yyyy', 'es').format(date)}',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(route),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: Icon(actionIcon, size: 18),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontFamily: 'Manrope',
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

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: _onSurfaceVariantColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: _onSurfaceVariantColor.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _emptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) =>
    Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _secondaryColor, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _onSurfaceVariantColor.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );

Widget _errorBox(String msg) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAD6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: _errorColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
