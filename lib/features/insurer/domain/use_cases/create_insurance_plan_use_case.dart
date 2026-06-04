import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_type.dart';
import 'package:water_ledger/features/insurer/domain/repositories/insurance_repository.dart';

class CreateInsurancePlanUseCase {
  const CreateInsurancePlanUseCase(this._repository);
  final InsuranceRepository _repository;

  Future<void> call({
    required String requestId,
    required String insurerId,
    required InsurancePlanType planType,
    required double coverageAmount,
    required double premiumRate,
    required String notes,
  }) =>
      _repository.createInsurancePlan(
        requestId: requestId,
        insurerId: insurerId,
        planType: planType,
        coverageAmount: coverageAmount,
        premiumRate: premiumRate,
        notes: notes,
      );
}
