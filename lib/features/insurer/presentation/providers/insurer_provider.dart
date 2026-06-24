import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/presentation/providers/repository_provider.dart';
import 'package:water_ledger/features/insurer/presentation/providers/insurance_repository_provider.dart';

/// Solicitudes con status='insured' visibles para todos los aseguradores —
/// excluye las que ya tienen un plan creado (issued o rejected).
/// StreamProvider (no FutureProvider): se actualiza solo cuando cambia el
/// status de una creditRequest, sin necesitar refresh manual. El batch write
/// de createInsurancePlan/rejectInsurance toca 'updatedAt' de la misma
/// creditRequest, así que este stream se reevalúa apenas se crea el plan.
final insuredRequestsProvider = StreamProvider<List<CreditRequestEntity>>((ref) {
  final repo = ref.watch(creditIssuanceRepositoryProvider);
  final insuranceRepo = ref.watch(insuranceRepositoryProvider);
  return repo.watchInsuredRequests().asyncMap((requests) async {
    final plans = await Future.wait(requests.map((r) => insuranceRepo.getInsurancePlan(r.id)));
    return [
      for (var i = 0; i < requests.length; i++)
        if (plans[i] == null) requests[i],
    ];
  });
});

/// Detalle de una solicitud — usado por la pantalla de detalle del asegurador.
final insurerRequestDetailProvider =
    FutureProvider.family<CreditRequestEntity, String>((ref, requestId) {
  return ref.read(creditIssuanceRepositoryProvider).getRequestById(requestId);
});

/// Conteo de planes de seguro activos/rechazados creados por este asegurador —
/// usado por las KPI cards del dashboard.
class InsurerStats {
  final int active;
  final int rejected;
  final int today;

  const InsurerStats({required this.active, required this.rejected, required this.today});
}

final insurerStatsProvider =
    StreamProvider.autoDispose.family<InsurerStats, String>((ref, uid) {
  if (uid.isEmpty) {
    return Stream.value(const InsurerStats(active: 0, rejected: 0, today: 0));
  }
  return FirebaseFirestore.instance
      .collection('insurancePlans')
      .where('insurerId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final now = DateTime.now();
    var active = 0, rejected = 0, today = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      if (status == 'active') active++;
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
    return InsurerStats(active: active, rejected: rejected, today: today);
  });
});
