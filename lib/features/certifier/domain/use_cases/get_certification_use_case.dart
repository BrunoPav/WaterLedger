import 'package:water_ledger/features/certifier/domain/entities/certification_entity.dart';
import 'package:water_ledger/features/certifier/domain/repositories/certification_repository.dart';

class GetCertificationUseCase {
  const GetCertificationUseCase(this._repository);
  final CertificationRepository _repository;

  Future<CertificationEntity?> call(String requestId) =>
      _repository.getCertification(requestId);
}
