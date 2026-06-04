import 'package:water_ledger/features/auditor/domain/entities/audit_entity.dart';
import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';

class AddObservationUseCase {
  final AuditRepository repository;
  AddObservationUseCase(this.repository);

  Future<void> call({
    required String requestId,
    required AuditObservation observation,
  }) =>
      repository.addObservation(requestId: requestId, observation: observation);
}
