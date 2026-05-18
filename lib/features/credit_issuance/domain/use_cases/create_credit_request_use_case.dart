import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class CreateCreditRequestUseCase {
  final CreditIssuanceRepository repository;

  CreateCreditRequestUseCase(this.repository);

  Future<CreditRequestEntity> call(String companyId) {
    return repository.createDraft(companyId: companyId);
  }
}
