import 'package:water_ledger/features/credit_issuance/domain/repository/credit_issuance_repository.dart';

class SubmitCreditRequestUseCase {
  final CreditIssuanceRepository repository;
  SubmitCreditRequestUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.submitRequest(requestId: requestId);
  }
}
