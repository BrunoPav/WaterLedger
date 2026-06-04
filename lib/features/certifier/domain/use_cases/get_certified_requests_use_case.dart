import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class GetCertifiedRequestsUseCase {
  const GetCertifiedRequestsUseCase(this._repository);
  final CreditIssuanceRepository _repository;

  Future<List<CreditRequestEntity>> call() => _repository.getCertifiedRequests();
}
