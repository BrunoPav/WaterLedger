import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repository/credit_issuance_repository.dart';

class CreateCreditDraftUseCase {
  final CreditIssuanceRepository repository;

  CreateCreditDraftUseCase(this.repository);

  Future<CreditRequestEntity> call(String companyId) {
    return repository.createDraft(companyId: companyId);
  }
}
