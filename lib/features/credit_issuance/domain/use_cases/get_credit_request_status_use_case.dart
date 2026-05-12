import 'package:water_ledger/features/credit_issuance/domain/enums/request_status.dart';
import 'package:water_ledger/features/credit_issuance/domain/repository/credit_issuance_repository.dart';

class GetCreditRequestStatusUseCase {
  
  final CreditIssuanceRepository repository;

  GetCreditRequestStatusUseCase(this.repository);

  Future<RequestStatus> call(String requestId) async {
    final request = await repository.getRequestById(requestId);
    return request.status;
  }
}