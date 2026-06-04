import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_ledger/features/certifier/presentation/providers/certifier_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';

const _bgColor               = Color(0xFFF7F9FB);
const _primaryColor          = Color(0xFF000000);
const _secondaryColor        = Color(0xFF006875);
const _onSurfaceColor        = Color(0xFF191C1E);
const _onSurfaceVariantColor = Color(0xFF44474D);
const _outlineVariantColor   = Color(0xFFC5C6CD);
const _surfaceColor          = Color(0xFFFFFFFF);
const _certifiedColor        = Color(0xFF2E7D32);

class CertifierRequestsScreen extends ConsumerWidget {
  const CertifierRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(certifiedRequestsProvider);

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
          'Solicitudes a Certificar',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _onSurfaceVariantColor),
            onPressed: () => ref.invalidate(certifiedRequestsProvider),
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _secondaryColor)),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(certifiedRequestsProvider)),
        data: (requests) => requests.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                color: _secondaryColor,
                onRefresh: () => ref.refresh(certifiedRequestsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _RequestTile(
                    request: requests[i],
                    onTap: () => context.push('/certifier-request-detail/${requests[i].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Request tile ──────────────────────────────────────────────────────────────
class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request, required this.onTap});

  final CreditRequestEntity request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final projectName = request.project?.name;
    final date = request.submittedAt ?? request.createdAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _certifiedColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined, color: _certifiedColor, size: 22),
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
                      color: projectName != null ? _onSurfaceColor : _onSurfaceVariantColor,
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
                      color: _onSurfaceVariantColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _certifiedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: _certifiedColor.withValues(alpha: 0.25)),
                        ),
                        child: const Text(
                          'Aprobado por Auditoría',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _certifiedColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM yyyy', 'es').format(date),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _onSurfaceVariantColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _onSurfaceVariantColor, size: 20),
          ],
        ),
      ),
    );
  }
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
                color: _secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined, color: _secondaryColor, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin solicitudes para certificar',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las solicitudes aprobadas por auditoría aparecerán aquí para su certificación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _onSurfaceVariantColor,
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
            const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 48),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar las solicitudes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verificá tu conexión e intentá nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: _onSurfaceVariantColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
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
