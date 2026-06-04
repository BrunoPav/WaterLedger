import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';

class StartAuditUseCase {
  final AuditRepository repository;
  StartAuditUseCase(this.repository);

  Future<void> call({required String requestId, required String auditorId}) =>
      repository.startAudit(requestId: requestId, auditorId: auditorId);
}
