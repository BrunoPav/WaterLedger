import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/auth/presentation/providers/session_provider.dart';
import 'package:water_ledger/features/certifier/domain/enums/certification_status.dart';
import 'package:water_ledger/features/certifier/presentation/providers/certification_repository_provider.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Solicitudes con status='certified' visibles para todos los certificadores.
final certifiedRequestsProvider = FutureProvider<List<CreditRequestEntity>>((ref) async {
  return ref.read(creditIssuanceRepositoryProvider).getCertifiedRequests();
});

/// Métricas del dashboard del certificador.
class CertifierStats {
  final int pending;   // solicitudes esperando certificación (status='certified')
  final int approved;  // certificados emitidos por este certificador
  final int rejected;  // certificaciones rechazadas por este certificador
  final int today;     // decisiones tomadas hoy (emitidas o rechazadas)

  const CertifierStats({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.today,
  });
}

/// Calcula las KPIs del dashboard combinando las solicitudes pendientes
/// con el historial de certificaciones del certificador logueado.
final certifierStatsProvider = FutureProvider.autoDispose<CertifierStats>((ref) async {
  final certifierId = ref.watch(sessionProvider).value?.uid ?? '';

  final pendingRequests =
      await ref.read(creditIssuanceRepositoryProvider).getCertifiedRequests();

  final certifications = certifierId.isEmpty
      ? const []
      : await ref
          .read(certificationRepositoryProvider)
          .getCertifierCertifications(certifierId);

  final now = DateTime.now();
  bool isToday(DateTime d) =>
      d.year == now.year && d.month == now.month && d.day == now.day;

  var approved = 0;
  var rejected = 0;
  var today = 0;
  for (final c in certifications) {
    if (c.status == CertificationStatus.issued) {
      approved++;
    } else {
      rejected++;
    }
    if (isToday(c.issuedAt ?? c.updatedAt)) today++;
  }

  return CertifierStats(
    pending: pendingRequests.length,
    approved: approved,
    rejected: rejected,
    today: today,
  );
});

/// Detalle de una solicitud — usado por la pantalla de detalle del certificador.
final certifierRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});
