import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';

class GetAuditUseCase {
  final AuditRepository repository;
  GetAuditUseCase(this.repository);

  Future<AuditEntity?> call(String requestId) => repository.getAudit(requestId);
}
