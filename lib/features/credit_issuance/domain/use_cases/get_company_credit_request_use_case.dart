import 'package:water_ledger/features/credit_issuance/domain/entities/credit_request_entity.dart';
import 'package:water_ledger/features/credit_issuance/domain/repositories/credit_issuance_repository.dart';

class GetCompanyCreditRequestUseCase {
  final CreditIssuanceRepository repository;

  GetCompanyCreditRequestUseCase(this.repository);

  Future<List<CreditRequestEntity>> call(String companyId) async {
    final List<CreditRequestEntity> requests = await repository.getCompanyRequests(companyId);
    return requests;
  }
}