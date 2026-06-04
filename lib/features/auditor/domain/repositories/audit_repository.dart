import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';

abstract class AuditRepository {
  Future<AuditEntity?> getAudit(String requestId);

  Stream<AuditEntity?> auditStream(String requestId);

  Future<void> startAudit({
    required String requestId,
    required String auditorId,
  });

  Future<void> addObservation({
    required String requestId,
    required AuditObservation observation,
  });

  Future<void> deleteObservation({
    required String requestId,
    required String observationId,
  });

  /// Persiste la conclusión y transiciona el estado de la creditRequest:
  /// approve → certified, reject → rejected, needsMoreInfo → sin cambio.
  Future<void> submitConclusion({
    required String requestId,
    required AuditConclusion conclusion,
  });
}
