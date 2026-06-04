import 'package:water_ledger/features/insurer/domain/entities/insurance_plan_entity.dart';
import 'package:water_ledger/features/insurer/domain/enums/insurance_plan_type.dart';

abstract class InsuranceRepository {
  Future<InsurancePlanEntity?> getInsurancePlan(String requestId);

  Stream<InsurancePlanEntity?> insurancePlanStream(String requestId);

  /// Crea el plan y transiciona creditRequest → 'valued'.
  Future<void> createInsurancePlan({
    required String requestId,
    required String insurerId,
    required InsurancePlanType planType,
    required double coverageAmount,
    required double premiumRate,
    required String notes,
  });

  /// Rechaza y transiciona creditRequest → 'rejected'.
  Future<void> rejectInsurance({
    required String requestId,
    required String insurerId,
    required String notes,
  });
}
