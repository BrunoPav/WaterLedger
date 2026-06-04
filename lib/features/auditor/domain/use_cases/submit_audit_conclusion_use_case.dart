import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';

class SubmitAuditConclusionUseCase {
  final AuditRepository repository;
  SubmitAuditConclusionUseCase(this.repository);

  Future<void> call({
    required String requestId,
    required AuditConclusion conclusion,
  }) =>
      repository.submitConclusion(requestId: requestId, conclusion: conclusion);
}
