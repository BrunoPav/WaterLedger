import 'package:water_ledger/features/certifier/domain/repositories/certification_repository.dart';

class RejectCertificationUseCase {
  const RejectCertificationUseCase(this._repository);
  final CertificationRepository _repository;

  Future<void> call({
    required String requestId,
    required String certifierId,
    required String notes,
  }) =>
      _repository.rejectCertification(
        requestId: requestId,
        certifierId: certifierId,
        notes: notes,
      );
}
