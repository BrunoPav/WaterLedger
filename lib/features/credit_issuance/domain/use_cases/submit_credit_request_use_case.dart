import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class SubmitCreditRequestUseCase {
  final CreditIssuanceRepository repository;
  SubmitCreditRequestUseCase(this.repository);

  /// Envía la solicitud de crédito (cambia estado a pending, registra fecha de envío)
  /// y devuelve la solicitud actualizada para mostrar confirmación.
  Future<CreditRequestEntity> call(String requestId) async {
    await repository.submitRequest(requestId: requestId);
    return await repository.getRequestById(requestId);
  }
}
