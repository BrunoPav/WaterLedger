import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';

/// Solicitudes con status='certified' visibles para todos los certificadores.
/// StreamProvider (no FutureProvider): se actualiza solo cuando una solicitud
/// entra o sale de 'certified', sin necesitar refresh manual.
final certifiedRequestsProvider = StreamProvider<List<CreditRequestEntity>>((ref) {
  return ref.watch(creditIssuanceRepositoryProvider).watchCertifiedRequests();
});

/// Detalle de una solicitud — usado por la pantalla de detalle del certificador.
final certifierRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});

/// Conteo de certificaciones emitidas/rechazadas por este certificador —
/// usado por las KPI cards del dashboard.
class CertifierStats {
  final int approved;
  final int rejected;
  final int today;

  const CertifierStats({required this.approved, required this.rejected, required this.today});
}

final certifierStatsProvider =
    StreamProvider.autoDispose.family<CertifierStats, String>((ref, uid) {
  if (uid.isEmpty) {
    return Stream.value(const CertifierStats(approved: 0, rejected: 0, today: 0));
  }
  return FirebaseFirestore.instance
      .collection('certifications')
      .where('certifierId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final now = DateTime.now();
    var approved = 0, rejected = 0, today = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      if (status == 'issued') approved++;
      if (status == 'rejected') rejected++;
      final createdAtRaw = data['createdAt'];
      final createdAt = createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw as String? ?? '');
      if (createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day) {
        today++;
      }
    }
    return CertifierStats(approved: approved, rejected: rejected, today: today);
  });
});
