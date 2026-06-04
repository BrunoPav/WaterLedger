import 'package:water_ledger/features/auditor/domain/repositories/audit_repository.dart';

class DeleteObservationUseCase {
  final AuditRepository repository;
  DeleteObservationUseCase(this.repository);

  Future<void> call({
    required String requestId,
    required String observationId,
  }) =>
      repository.deleteObservation(
        requestId: requestId,
        observationId: observationId,
      );
}
