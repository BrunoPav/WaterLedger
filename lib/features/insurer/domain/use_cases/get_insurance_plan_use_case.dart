import 'package:water_ledger/features/insurer/domain/entities/insurance_plan_entity.dart';
import 'package:water_ledger/features/insurer/domain/repositories/insurance_repository.dart';

class GetInsurancePlanUseCase {
  const GetInsurancePlanUseCase(this._repository);
  final InsuranceRepository _repository;

  Future<InsurancePlanEntity?> call(String requestId) =>
      _repository.getInsurancePlan(requestId);
}
