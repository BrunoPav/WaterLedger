import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/company_requests_provider.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/credit_request_notifier.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';
import 'package:water_ledger/features/dashboards/presentation/widgets/dashboard_tokens.dart';

class CompanyRequestsListScreen extends ConsumerWidget {
  const CompanyRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(companyRequestsProvider);

    return Scaffold(
      backgroundColor: DashboardTokens.bgColor,
      appBar: AppBar(
        backgroundColor: DashboardTokens.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DashboardTokens.onSurfaceColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Solicitudes Activas',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: DashboardTokens.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: DashboardTokens.onSurfaceVariantColor),
            onPressed: () => ref.invalidate(companyRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: DashboardTokens.secondaryColor,
          ),
        ),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(companyRequestsProvider)),
        data: (requests) {
          final active = requests
              .where((r) =>
                  r.status != RequestStatus.published &&
                  r.status != RequestStatus.rejected)
              .toList()
            ..sort((a, b) {
              final aDate = a.submittedAt ?? a.createdAt;
              final bDate = b.submittedAt ?? b.createdAt;
              return bDate.compareTo(aDate);
            });

          if (active.isEmpty) return const _EmptyState();

          void continueDraft(CreditRequestEntity draft) {
            ref.read(creditRequestProvider.notifier).loadDraft(draft);
            context.push('/credit-issuance');
          }

          Future<void> deleteDraft(CreditRequestEntity draft) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(
                  'Eliminar borrador',
                  style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
                ),
                content: const Text(
                  '¿Querés eliminar este borrador? Esta acción no se puede deshacer.',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: DashboardTokens.errorColor),
                    ),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            try {
              await ref.read(creditIssuanceRepositoryProvider).deleteDraft(draft.id);
              ref.invalidate(companyRequestsProvider);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo eliminar el borrador.')),
                );
              }
            }
          }

          return RefreshIndicator(
            color: DashboardTokens.secondaryColor,
            onRefresh: () => ref.refresh(companyRequestsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: active.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = active[i];
                final isDraft = r.status == RequestStatus.draft;
                return _RequestTile(
                  request: r,
                  onTap: isDraft
                      ? () => continueDraft(r)
                      : () => context.push('/request-tracking/${r.id}'),
                  onDelete: isDraft ? () => deleteDraft(r) : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Tile de request ───────────────────────────────────────────────────────────
class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.onTap,
    this.onDelete,
  });

  final CreditRequestEntity request;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final projectName = request.project?.name;
    final date = request.submittedAt ?? request.createdAt;
    final (statusLabel, statusColor) = _statusMeta(request.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: DashboardTokens.outlineVariantColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pending_outlined, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
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
                    'ID: ${request.id.substring(0, request.id.length.clamp(0, 8))}…',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: DashboardTokens.onSurfaceVariantColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM yyyy', 'es').format(date),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: DashboardTokens.onSurfaceVariantColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: DashboardTokens.errorColor,
                tooltip: 'Eliminar borrador',
                onPressed: onDelete,
              )
            else
              const Icon(
                Icons.chevron_right,
                color: DashboardTokens.onSurfaceVariantColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statusMeta(RequestStatus status) => switch (status) {
        RequestStatus.draft      => ('Borrador',      const Color(0xFF78909C)),
        RequestStatus.pending    => ('Pendiente',     const Color(0xFFF57C00)),
        RequestStatus.underAudit => ('En auditoría',  const Color(0xFF1565C0)),
        RequestStatus.certified  => ('Certificado',   const Color(0xFF2E7D32)),
        RequestStatus.insured    => ('Asegurado',     const Color(0xFF00695C)),
        RequestStatus.valued     => ('Valorizado',    const Color(0xFF6A1B9A)),
        RequestStatus.published  => ('Publicado',     const Color(0xFF006875)),
        RequestStatus.rejected   => ('Rechazado',     const Color(0xFFC62828)),
      };
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DashboardTokens.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_outlined,
                color: DashboardTokens.secondaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin solicitudes activas',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tus solicitudes en curso aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: DashboardTokens.onSurfaceVariantColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: DashboardTokens.errorColor, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DashboardTokens.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verificá tu conexión e intentá nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: DashboardTokens.onSurfaceVariantColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardTokens.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
