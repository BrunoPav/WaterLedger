import 'package:water_ledger/features/credit_issuance/domain/repository/credit_issuance_repository.dart';

class DeleteDraftUseCase {
  final CreditIssuanceRepository repository;

  DeleteDraftUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.deleteDraft(requestId);
  }
}